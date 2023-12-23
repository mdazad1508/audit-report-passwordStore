// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/*
 * @author not-so-secure-dev
 * @title PasswordStore
 * @notice This contract allows you to store a private password that others won't be able to see. 
 * You can update your password at any time.
 */
contract PasswordStore {
    error PasswordStore__NotOwner();

    address private s_owner;
    // @audit nothing is private on chain , so it is not a secure way to save your password.
    string private s_password;

    event SetNetPassword();

    constructor() {
        s_owner = msg.sender;
    }

    /*
     * @notice This function allows the owner to set a new password.
     * @param newPassword The new password to set.
     * can a non owner set password here ? 
     * yes any user can set a password here .
     * @audit : HIGH , missing access modifier OnlyOwner.
     */

    function setPassword(string memory newPassword) external {  //missing access modifier
        s_password = newPassword;
        emit SetNetPassword();
    }

    /*
     * @notice This allows only the owner to retrieve the password.
     * @audit : the new password params in missing here 
     * @audit : NO functionality to set the new password here
     * @param newPassword The new password to set.
     */
    function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
}
