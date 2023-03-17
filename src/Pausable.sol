// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Pausable {
    event Paused(address pausableAccount);
    event Unpaused(address pausableAccount);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpaused() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}