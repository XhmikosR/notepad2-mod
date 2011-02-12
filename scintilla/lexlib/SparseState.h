// Scintilla source code edit control
/** @file SparseState.h
 ** Hold lexer state that may change rarely.
 ** This is often per-line state such as whether a particular type of section has been entered.
 ** A state continues until it is changed.
 **/
// Copyright 2011 by Neil Hodgson <neilh@scintilla.org>
// The License.txt file describes the conditions under which this software may be distributed.

#ifndef SPARSESTATE_H
#define SPARSESTATE_H

#ifdef SCI_NAMESPACE
namespace Scintilla {
#endif

template <typename T>
class SparseState {
	struct State {
		int position;
		T value;
		State(int position_, T value_) : position(position_), value(value_) {
		}
		inline bool operator<(const State &other) const {
			return position < other.position;
		}
	};
	typedef std::vector<State> stateVector;
	stateVector states;
public:
	void Set(int position, T value) {
		Delete(position);
		if ((states.size() == 0) || (value != states[states.size()-1].value)) {
			states.push_back(State(position, value));
		}
	}
	T ValueAt(int position) {
		if (!states.size())
			return T();
		if (position < states[0].position)
			return T();
		State searchValue(position, T());
		typename stateVector::iterator low =
			lower_bound(states.begin(), states.end(), searchValue);
		if (low == states.end()) {
			return states[states.size()-1].value;
		} else {
			if (low->position > position) {
				low--;
			}
			return low->value;
		}
	}
	bool Delete(int position) {
		State searchValue(position, T());
		typename stateVector::iterator low =
			lower_bound(states.begin(), states.end(), searchValue);
		if (low != states.end()) {
			states.erase(low, states.end());
			return true;
		}
		return false;
	}
	size_t size() {
		return states.size();
	}
};

#ifdef SCI_NAMESPACE
}
#endif

#endif
