// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PokeBin is ERC721 {

    struct Pokemon {
        string name;
        uint level;
        string img;
        address owner;
    }

    Pokemon[] public pokemons;
    address public gameOwner;

    event PokemonCreated(uint indexed tokenId, string name, address owner);
    event BattleOutcome(uint indexed attackerId, uint indexed defenderId, bool attackerWins);

    constructor() ERC721("PokeDIO", "PKD") {
        gameOwner = msg.sender;
    }

    function createNewPokemon(string memory _name, string memory _img) public {
        require(msg.sender == gameOwner, "Apenas o dono do jogo pode criar novos Pokemons");
        uint tokenId = pokemons.length;
        pokemons.push(Pokemon(_name, 1, _img, msg.sender));
        _safeMint(msg.sender, tokenId);
        emit PokemonCreated(tokenId, _name, msg.sender);
    }

    modifier onlyOwnerOf(uint _monsterId) {
        require(ownerOf(_monsterId) == msg.sender, "Apenas o dono pode batalhar com este Pokemon");
        _;
    }

    function battle(uint _attackingPokemon, uint _defendingPokemon) public onlyOwnerOf(_attackingPokemon) {
        Pokemon storage attacker = pokemons[_attackingPokemon];
        Pokemon storage defender = pokemons[_defendingPokemon];

        bool attackerWins = attacker.level >= defender.level;

        if (attackerWins) {
            attacker.level += 2;
            defender.level += 1;
        } else {
            attacker.level += 1;
            defender.level += 2;
        }

        emit BattleOutcome(_attackingPokemon, _defendingPokemon, attackerWins);
    }
}
