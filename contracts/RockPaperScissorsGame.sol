// SPDX-License-Identifier: MIT
//Excercise 1 Contracts (last updated v1.0)
pragma solidity ^0.8.5;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev _Available since v1.0
 */
contract RockPaperScissorsGame  {
    /** @dev
     ERC20 to bet
    **/
    ERC20 private wrapped;

    /**
     * @dev Emitted when the game start, the game start is the moment when a opponent accept the challenge,
      player 1 and player 2 are the players and round is the number of round to finish the game
     *
    */
    event GameStart (
        address  player1,
        address  player2,
        uint8   rounds
    );
    /**
     * @dev Emitted when finish the game with one winner and loser in the case of draw check the GameDraw event
     *
    */
    event GameFinish (
        address  loser,
        address winner
    );
    /**
     * @dev Emitted when finish the game without winner and the 2 players of game have the same victories
    */
    event GameDraw (
        address   player1,
        address  player2
    );

    /**
     * @dev Emitted when finish a round
      Note: In the case of draw send 2  address as winners
    */
    event RoundFinish (
        address[]  winners
    );

    /**
     * @dev  status is a uint beacause 0 is a inactive game , 1 is a active game but waiting 
     for the player 2 and status 2  when the game is being played
    */
    struct Game {
        address player1;
        address player2;
        uint8 rounds;
        uint8  currentMovePlayer1;
        uint8  currentMovePlayer2;
        uint8  victoriesPlayer1;
        uint8  victoriesPlayer2;
        uint8  currentRound;
        address[]  winners;
        uint8 status;
    }

    /**
     * @dev Indices are signed integers because   we can grow the current game to many  games at the same time, using diferent index.
        At the moment only I use the index 0 to play only one game with 2 players
     */
    mapping (uint256 => Game) private games;


    /**
        @dev this method is called when a address  wants to start a game with other address
        Requirements:
        @param  opponent  is the opponent
        @param rounds thee quantity of round by game
    */
    function startChallenge(address opponent, uint8 rounds) public returns(bool) {
        require(games[0].status == 0, "RockPaperScissors: Have a challenge initializated");
        require(opponent != address(this), "RockPaperScissors: Invalid opponet");
        require(opponent != address(0), "RockPaperScissors: Invalid opponet");
        require(rounds > 0, "RockPaperScissors: rounds must be greatter than 0");
        require(rounds < 11, "RockPaperScissors: rounds must be less  than 11");
        games[0].player1 = msg.sender;
        games[0].player2 = opponent;
        games[0].rounds = rounds;
        games[0].status = 1;
        return true;
    }
    /**
        @dev this method  only works with the player2 (opponent), in this method the opponent accept the game and start the game after that player 1
        must be to call one method, rock,paper or scissor
    */
    function acceptChallenge() public returns(bool) {
        require(games[0].status == 1, "RockPaperScissors: status invalid");
        require(games[0].player2 == msg.sender, "RockPaperScissors: You  are not the correct oponnet");
        games[0].player2 = msg.sender;
        games[0].status = 2;
        emit GameStart(games[0].player1,games[0].player2,games[0].rounds);
        return true;
    }
    /**
        @dev this method  only works with the player1 if the player1 regrets can delete de game to challenge another
    */

    function deleteChallenge() public returns(bool) {
        require(games[0].player2 == msg.sender || games[0].player1 == msg.sender, "RockPaperScissors: You  are not a player");
        require(games[0].status == 1, "RockPaperScissors: status invalid");
        delete games[0];
        return true;
    }
    /**
        @dev  validate if the current round is valid
        @param  gameID  id of game (only 0 for now)
        NOTE: In the case of have many game in the future pass another gameID diferent of 0, by the moment only 0
    */
    function validateRound(uint256 gameID) internal view {
        require(games[gameID].status == 2, "RockPaperScissors: This game is invalid");
        require(getCurrentRound(gameID) < games[gameID].rounds, "RockPaperScissors: This game finish");
    }

    function getCurrentRound(uint256 gameID) internal view returns(uint8) {
        return games[gameID].currentRound;
    }
    /**
        @dev  the player with most rounds won, win the game with
        @param  gameID  id of game (only 0 for now)
        NOTE: In the case of draw emmit draw and end the game, in the future can add more rounds until have a winner
    */
    function validateWinnerOfGame(uint256 gameID) internal {
        if(games[gameID].victoriesPlayer1 == games[gameID].victoriesPlayer2) {
            emit GameDraw( games[gameID].player1,  games[gameID].player2);
        } else if(games[gameID].victoriesPlayer1 > games[gameID].victoriesPlayer2) {
            emit GameFinish( games[gameID].player2,  games[gameID].player1);
        } else {
            emit GameFinish( games[gameID].player1,  games[gameID].player2);
        }
        delete games[gameID];
    }
    /**
        @param  gameID  id of game (only 0 for now)
    */
    function validateWinnerOfRound(uint256 gameID) internal {
        delete games[gameID].winners;
        require(games[gameID].currentMovePlayer1 > 0 &&  games[gameID].currentMovePlayer2 > 0, "RockPaperScissors: One player does not play");
        if (games[gameID].currentMovePlayer1 == games[gameID].currentMovePlayer2) {
            games[gameID].victoriesPlayer2++;
            games[gameID].victoriesPlayer1++;
            games[gameID].winners.push(games[gameID].player1);
            games[gameID].winners.push(games[gameID].player2);
        }else if(games[gameID].currentMovePlayer1 == 1 &&  games[gameID].currentMovePlayer2 == 3) {
            games[gameID].victoriesPlayer2++;
            games[gameID].winners.push(games[gameID].player2);
        } else if (games[gameID].currentMovePlayer1 == 3 &&  games[gameID].currentMovePlayer2 == 2) {
            games[gameID].victoriesPlayer2++;
            games[gameID].winners.push(games[gameID].player2);
        } else if (games[gameID].currentMovePlayer1 == 2 &&  games[gameID].currentMovePlayer2 == 1) {
            games[gameID].victoriesPlayer2++;
            games[gameID].winners.push(games[gameID].player2);
        } else if(games[gameID].currentMovePlayer1 == 3 &&  games[gameID].currentMovePlayer2 == 1) {
            games[gameID].victoriesPlayer1++;
            games[gameID].winners.push(games[gameID].player1);
        }else if(games[gameID].currentMovePlayer1 == 2 &&  games[gameID].currentMovePlayer2 == 3) {
            games[gameID].victoriesPlayer1++;
            games[gameID].winners.push(games[gameID].player1);
        }else if(games[gameID].currentMovePlayer1 == 1 &&  games[gameID].currentMovePlayer2 == 2) {
            games[gameID].victoriesPlayer1++;
            games[gameID].winners.push(games[gameID].player1);
        }
        emit RoundFinish(games[gameID].winners);
         games[gameID].currentMovePlayer2 = 0;
         games[gameID].currentMovePlayer1  = 0;
        games[gameID].currentRound++;
        if(games[gameID].currentRound == games[gameID].rounds) {
            validateWinnerOfGame(gameID);
        }
    }

    /**
        @dev  When a player call  rock,paper or scissor call this method to save his movement and if the player 2 call this method validate if won
        @param  gameID  id of game (only 0 for now)
    */
    function updateMovePlayer(uint256 gameID, uint8 move) internal {
        if(games[gameID].player1 == msg.sender) {
            require(games[gameID].currentMovePlayer1 == 0 &&  games[gameID].currentMovePlayer2 == 0, "RockPaperScissors: Wait for your turn");
            games[gameID].currentMovePlayer1 = move;
        } else {
            require(games[gameID].player2 == msg.sender  , "RockPaperScissors: You  are not a player");
            require(games[gameID].currentMovePlayer1 > 0 &&  games[gameID].currentMovePlayer2 == 0, "RockPaperScissors: Wait for your turn");
            games[gameID].currentMovePlayer2 = move;
            validateWinnerOfRound(gameID);
        }
    }
   /**
        @dev  0 is the id of game and 1 is the id for rock
    */
    function rock() external {
        validateRound(0);
        updateMovePlayer(0,1);
    }
   /**
        @dev  0 is the id of game and 2 is the id for scissor
    */
    function scissor() external {
        validateRound(0);
        updateMovePlayer(0,2);
    }

   /**
        @dev  0 is the id of game and 3 is the id for paper
    */
    function paper() external {
        validateRound(0);
        updateMovePlayer(0,3);
    }
}