### [S-High1] Storing password on-chain makes it visible to anyone irrespective to solidity access modifier.

**Description:** 
Any one can access on-chain data even if its private , using the knowledge of storage slot . Thus storing 
password on-chain will make it accessible to everyone . Anyone can read stored password even if its private on contract  


Here `PasswordStore::s_password` stroge variable can be read on-chain which is intented to be private by 
calling function `PasswordStore::getPassword` .

**Impact:** 
This will expose your private password to everyone using blockchain , which can lead to severe vulnarability .


**Proof of Concept:**
Proof of code to access storage variable `s_password` which is private 

***steps***
1. Deploy the below script 

```javascript
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {PasswordStore} from "../src/PasswordStore.sol";

contract DeployPasswordStore is Script {
    function run() public returns (PasswordStore) {
        vm.startBroadcast();
        PasswordStore passwordStore = new PasswordStore();
        passwordStore.setPassword("@thisIsMyPassword");
        vm.stopBroadcast();
        return passwordStore;
    }
}

```
2. Starting a local node 
   
   ```make anvil```

3. Deploy PasswordStore 
   
   ```make deploy```

4. Access storage slot 1 using cast
   
    ```ast storage 0x5FbDB2315678afecb367f032d93F642f64180aa3 1 --rpc-url http://127.0.0.1:8545```

5. convert slot 1 data from bytes32 to string 
   
   ```cast parse-bytes32-string 0x407468697349734d7950617373776f7264000000000000000000000000000022```
   * OUTPUT : @thisIsMyPassword
   * set Password : @thisIsMyPassword

Thus proved !, we can access private s_password 


**Recommended Mitigation:**
Since the password will be stored on-chain no matter what, so its better to save encrypted password on-chain 
using another off-chain password that user needs to remember in other to decrypt password again . 



### [S-High2] No Acesss Modifier , Allows non-owners to set Password

**Description:** The `PasswordStore:: setPassword` function at line 31 , does not have access 
modifier which allows only owner to set the password . So any user who is not owner can set Password.

**Impact:** Any one can setPassword , causing severity into the protocol.

**Proof of Concept:**(Proof of Code) 
Add this test case to your `test/PasswordStore.t.sol`
```javascript
    function test_non_owner_can_setPassword(address random) public {
        vm.assume(random != owner);
        vm.startPrank(random);
        string memory setPassword = "somerandompassword";
        passwordStore.setPassword(setPassword);

        vm.startPrank(owner);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, setPassword);
    }
```

Run the above Fuzz test by : 
```forge test --mt test_non_owner_can_setPassword```

This test passes for random users other than owner 

```javascript [⠆] Compiling...
[⠔] Compiling 1 files with 0.8.18
[⠒] Solc 0.8.18 finished in 1.44s
Compiler run successful!

Running 1 test for test/PasswordStore.t.sol:PasswordStoreTest
[PASS] test_non_owner_can_setPassword(address) (runs: 600, μ: 23203, ~: 23203)
Test result: ok. 1 passed; 0 failed; 0 skipped; finished in 52.62ms
```


**Recommended Mitigation:** you can add an access modifier check , which checks that the user is only owner 
```diff
   function setPassword(string memory newPassword) external { 
+    if(msg.sender != owner){
       revert PasswordStore_NotOwner();
       }
        s_password = newPassword;
        emit SetNetPassword();
    }
``` 

### [S-Low] Parameters for getPassword Method is missing 

**Description:** The comment above function specifies that a string parameter needs to be passed into getPassword 
method and set it as new Password . But there is no parameters to `PasswordStore::getPassword()` function.
```@param newPassword The new password to set```

**Impact:** No serve Impact , fault in Documentation/Code

**Recommended Mitigation:** 

```diff
+    function getPassword(string newPassword) external view returns (string memory) {
-    function getPassword() external view returns (string memory) {
```
