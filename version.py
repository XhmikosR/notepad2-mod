import os, os.path
import re
import shlex
import subprocess

__doc__ = """
This is a python rewrite of update_rev.sh.

Author: Dejan Budimir
Date:   2018-07.19 02:13:00.000
"""


class dec(object):

	@staticmethod
	def dictstring(cls):
		setattr(cls, "__str__",
			lambda self: self.__class__.__name__ + str(self.__dict__))
		return cls


class path(object):

	@staticmethod
	def root():
		"""Return the folder which contains this file. This file should be located in the project's root folder i.e. 'notepad2-mod'."""
		return os.path.abspath(os.path.split(__file__)[0])

	@classmethod
	def make(cls, rel_path):
		"""Turn {rel_path} into a root-relative path."""
		return os.path.normpath(os.path.join(cls.root(), rel_path))


class run(object):

	@staticmethod
	def code(cmd_str, shell=False, no_stderr=True, no_stdout=True):
		"""Run the {cmd_str} and return the process's exit code."""
		return subprocess.call(cmd_str, shell=shell,
			stdout=(subprocess.PIPE if no_stdout else None),
			stderr=(subprocess.PIPE if no_stderr else None))

	@staticmethod
	def ok(*aa, **kk):
		"""Run the {cmd_str} and return True if exit code was 0."""
		return 0 == run.code(*aa, **kk)

	@staticmethod
	def out_old(cmd_str, shell=False, no_stderr=False, stripchars=None):
		"""{OBSOLETE} Run the {cmd_str} and return 2-tuple of (exit_code, stdout)."""
		if no_stderr:
			raise NotImplementedError("can deadlock based on the child process error volume; use Popen with the communicate()")
		try:
			stdout = subprocess.check_output(cmd_str, shell=shell,
				stderr=(subprocess.PIPE if no_stderr else None))
			if not stdout: return 0, ""
			return 0, stdout.strip(stripchars)
		except subprocess.CalledProcessError, e:
			r = re.match(r'.+?returned non-zero exit status (\d+)$', str(e))
			if not r: raise
			return int(r.group(1)), None

	@staticmethod
	def out(cmd_str, shell=False, no_stderr=True, stripchars=None):
		"""Run the {cmd_str} and return 2-tuple of (exit_code, stdout_text)."""
		args = shlex.split(cmd_str)
		child = subprocess.Popen(args, shell=shell,
			stdout=subprocess.PIPE,
			stderr=(subprocess.PIPE if no_stderr else None))
		stdout, stderr = child.communicate()
		if child.returncode:
			return child.returncode, None
		if not stdout: return 0, ""
		return 0, stdout.strip(stripchars)


class git(object):

	# This is the last svn changeset, the number and hash can be automatically
	# calculated, but it is slow to do that. So it is better to have it hardcoded.
	svnrev = 760
	svnhash = "0cd53aab71b006820233224bbf14c2b18b2caca6"

	@staticmethod
	def in_repo():
		return run.ok("git rev-parse --git-dir")

	@staticmethod
	def get_current_branch_name():
		exitcode, stdout = run.out("git symbolic-ref -q HEAD")
		if 0 == exitcode:
			return re.sub(r'refs/heads/', '', stdout)
		elif "APPVEYOR_REPO_BRANCH" in os.environ:
			return os.environ["APPVEYOR_REPO_BRANCH"]
		return "no branch"

	@staticmethod
	def ref_exists(exact_ref_path):
		return run.ok("git show-ref --verify --quiet " + exact_ref_path)

	@staticmethod
	def find_best_common_merge_base():
		exitcode, stdout = run.out("git merge-base master HEAD")
		if exitcode: return None
		return stdout

	@staticmethod
	def count_commits(base_ref="HEAD"):
		"""Return number of commits since project's move to Github, reachable from {base_ref}."""
		if not base_ref: base_ref = git.find_best_common_merge_base()
		exitcode, stdout = run.out("git rev-list --count %s..%s" % (git.svnhash, base_ref))
		if exitcode: return 0
		return int(stdout)

	@staticmethod
	def get_short_hash(ref="HEAD"):
		exitcode, stdout = run.out("git rev-parse --short %s" % ref)
		if exitcode: return None
		return stdout

	@staticmethod
	def working_tree_differs(ref="HEAD"):
		return not run.ok("git diff-index --quiet %s" % ref)


class file_t(object):
	"""Base class for {version_file_t} and {manifest_file_t}."""

	def __init__(self, root_relative_path):
		self.outpath = path.make(root_relative_path)

	def needs_update(self, new_contents):
		"""Compare {new_contents} with current file contents, return True if different."""
		if not os.path.exists(self.outpath): return True
		with open(self.outpath, "rb") as f:
			if f.read() != new_contents: return True
		return False

	def update(self, new_contents):
		"""Write {new_contents} to file."""
		with open(self.outpath, "wb") as f:
			f.write(new_contents)

	def generate(self, *aa, **kk):
		"""Override this in the subclass to generate new file contents based on input args."""
		raise NotImplementedError


class version_file_t(file_t):

	def __init__(self, outpath):
		super(version_file_t, self).__init__(outpath)

	def generate(self, vi):
		assert isinstance(vi, version_info_t)
		text = ""
		text += '#define BRANCH _T("%s")\n' % vi.branch
		text += '#define VERSION_HASH _T("%s")\n' % vi.hash
		text += '#define VERSION_REV %s\n' % vi.ver
		text += '#define VERSION_REV_FULL %s\n' % vi.ver_full
		return text


class manifest_file_t(file_t):

	def __init__(self, outpath, confpath=None):
		super(manifest_file_t, self).__init__(outpath)
		self.confpath = confpath or self.outpath + ".conf"

	def generate(self, vi):
		assert isinstance(vi, version_info_t)
		with open(self.confpath, "rb") as f:
			return re.sub(r'\$WCREV\$', str(vi.ver), f.read())


@dec.dictstring
class version_info_t(object):

	def __init__(self):

		# Get the abbreviated hash of the current changeset
		self.hash = git.get_short_hash("HEAD")

		# Count how many changesets we have since the last
		#	svn changeset, add to it last svn revision number.
		self.ver = git.count_commits("HEAD") + git.svnrev

		# Get the current branch name
		self.branch = git.get_current_branch_name()

		if "master" == self.branch:
			self.ver_full = ""
			self.base = ""
		else:
			# If we are on another branch that isn't master, we
			#	want extra info like on which commit from master
			#	it is based on and what its hash is. This assumes
			#	we won't ever branch from a changeset from before
			#	the move to git.
			if not git.ref_exists("refs/heads/master"):
				self.ver_full = " (%s)" % self.branch
			else:
				# Get where the branch is based on master
				self.base = git.find_best_common_merge_base()
				self.base_ver = git.count_commits(self.base) + git.svnrev

				self.ver_full = " (%s) (master@%s)" % (self.branch, str(self.base_ver)[0:7])

		self.ver_full = '_T("%s (%s)%s")' % (self.ver, self.hash, self.ver_full)

	def echo(self):
		# echo_format = '{0:<10s} {1}'
		echo_format = '%-10s %s'

		if self.branch:
			print echo_format % ("On branch:", self.branch)
		print echo_format % ("Hash:", self.hash)
		if self.branch and git.working_tree_differs():
			print echo_format % ("Revision:", "%s (Local modifications found)" % self.ver)
		else:
			print echo_format % ("Revision:", self.ver)
		if len(self.base):
			print echo_format % ("Mergebase:", 'master@%s (%s)') % (self.base_ver, self.base[0:7])


def main(pedantic=True):

	if not git.in_repo():
		raise Exception("this is not a git repository")

	if pedantic and not os.getcwd().startswith(path.root()):
		raise Exception("{pedantic=1} CWD \"%s\" is not in this script's folder tree \"%s\"." % (os.getcwd(), path.root()))

	version_info = version_info_t()
	# print version_info
	version_info.echo()

	version_file = version_file_t("./src/VersionRev.h")
	manifest_file = manifest_file_t("./res/Notepad2.exe.manifest")

	# Update VersionRev.h if it does not exist, or
	#	if version information was changed.
	newversioninfo = version_file.generate(version_info)
	if version_file.needs_update(newversioninfo):
		# Write the version information to VersionRev.h
		version_file.update(newversioninfo)

	# Update manifest file if it does not exist, or
	#	if source manifest.conf was changed.
	newmanifest = manifest_file.generate(version_info)
	if manifest_file.needs_update(newmanifest):
		manifest_file.update(newmanifest)


if "__main__" == __name__:
	main(pedantic=True)
