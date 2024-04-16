// SPDX-License-Identifier: MIT

/*
                                                                               
                                   8
                                   8
                        .,,aadd88P=8=Y88bbaa,,.
                  .,ad88888P:a8P:d888b:Y8a:Y88888ba,.
              ,ad888888P:a8888:a8888888a:8888a:Y888888ba,
           ,a8888888:d8888888:d888888888b:8888888b:8888888a,
        ,a88888888:d88888888:d88888888888b:88888888b:88888888a,
      ,d88888888:d888888888:d8888888888888b:888888888b:88888888b,
    ,d88888888:d8888888888I:888888888888888:I8888888888b:88888888b,
  ,d888888888:d88888888888:88888888888888888:88888888888b:888888888b,
 d8888888888:I888888888888:88888888888888888:888888888888I:8888888888b
d8P"'   `"Y8:8P"'     `"Y8:8P"'    8    `"Y8:8P"'     `"Y8:8P"'   `"Y8b
"           "             "        8        "             "           "
                                   8
                                   8
                                   8
                                   8
                                   8
                                   8
                                   8
                                   8
                                   8
                                  ,8,
                                  888
                                  888      __
                                  Y88b,,,d88P
                                  `Y8888888P'
                                    `"""""'                             

   ooooooooo.                                                   oooo 
   `888   `Y88.                                                 `888 
    888   .d88'  .oooo.   oooo d8b  .oooo.    .oooo.o  .ooooo.   888 
    888ooo88P'  `P  )88b  `888""8P `P  )88b  d88(  "8 d88' `88b  888 
    888          .oP"888   888      .oP"888  `"Y88b.  888   888  888 
    888         d8(  888   888     d8(  888  o.  )88b 888   888  888 
   o888o        `Y888""8o d888b    `Y888""8o 8""888P' `Y8bod8P' o888o

  https://parasol.blue

  #BuildOnBase

  This contract represents the simplest form of an ERC20 token. We made it ownable so that it can be renounced after deployment.
  This way, security tools can report that it is a renounced contract. It has no tax, no burn, no mint, no transfer fees.

*/

pragma solidity ^0.8.25;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Parasol is ERC20, Ownable {

    uint256 constant initialSupply = 10000000 * (10**18);

    // Constructor will be called on contract creation
    constructor() ERC20("Parasol", "PARA") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }
}