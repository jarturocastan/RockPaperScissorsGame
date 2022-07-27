const ethers =  require('ethers');
const helper = require("../helpers/time");
const truffleAssert = require('truffle-assertions');
const RockPaperScissorsGame = artifacts.require("RockPaperScissorsGame")

/** 
 * This test only test 3 round, we have to do more test using different rounds and using even numbers
*/
contract('RockPaperScissorsGame basis',accounts => {
    let rockPaperScissorsGame = null;
    let player1 = accounts[0]
    let player2 = accounts[1]
    beforeEach(async() => {
        rockPaperScissorsGame = await RockPaperScissorsGame.new();
    })


    it("Player1 start a challenge against player2 with 3 rounds", async () => {
        await rockPaperScissorsGame.startChallenge(player2,3, {from : player1})
    })

    it("Player2 accept a challenge against player 1", async () => {
        await rockPaperScissorsGame.startChallenge(player2,3, {from : player1})
        await rockPaperScissorsGame.acceptChallenge({from : player2})
    })

    it("Player1 win in 3 rounds", async () => {
        await rockPaperScissorsGame.startChallenge(player2,3, {from : player1})
        await rockPaperScissorsGame.acceptChallenge({from : player2})
        await rockPaperScissorsGame.rock({from : player1})
        let result = await rockPaperScissorsGame.scissor({from : player2})
        truffleAssert.eventEmitted(result, 'RoundFinish', (ev) => {
             return  ev.winners[0] == player1;
        },  'RoundFinish should be emitted with only one address (address of player1)');
        await rockPaperScissorsGame.paper({from : player1})
        result = await rockPaperScissorsGame.scissor({from : player2})
        truffleAssert.eventEmitted(result, 'RoundFinish', (ev) => {
            return  ev.winners[0] == player2;
       },  'RoundFinish should be emitted with only one address (address of player2)');
       await rockPaperScissorsGame.scissor({from : player1})
       result = await rockPaperScissorsGame.paper({from : player2})
       truffleAssert.eventEmitted(result, 'RoundFinish', (ev) => {
           return  ev.winners[0] == player1;
      },  'RoundFinish should be emitted with only one address (address of player1)');
      truffleAssert.eventEmitted(result, 'GameFinish', (ev) => {
        return  ev.winner == player1 && ev.loser == player2;
   },  'GameFinish should be emitted with only one winner (address of player1)');
    })

    it("Draw game  and draw 3 rounds", async () => {
        await rockPaperScissorsGame.startChallenge(player2,3, {from : player1})
        await rockPaperScissorsGame.acceptChallenge({from : player2})
        await rockPaperScissorsGame.rock({from : player1})
        let result = await rockPaperScissorsGame.rock({from : player2})
        truffleAssert.eventEmitted(result, 'RoundFinish', (ev) => {
             return  ev.winners[0] == player1 && ev.winners[1] == player2;
        },  'RoundFinish should be emitted with only one address (address of player1)');
        await rockPaperScissorsGame.paper({from : player1})
        result = await rockPaperScissorsGame.paper({from : player2})
        truffleAssert.eventEmitted(result, 'RoundFinish', (ev) => {
            return  ev.winners[0] == player1 && ev.winners[1] == player2;
       },  'RoundFinish should be emitted with only one address (address of player2)');
       await rockPaperScissorsGame.scissor({from : player1})
       result = await rockPaperScissorsGame.scissor({from : player2})
       truffleAssert.eventEmitted(result, 'RoundFinish', (ev) => {
           return  ev.winners[0] == player1 && ev.winners[1] == player2;
      },  'RoundFinish should be emitted with only one address (address of player1)');
      truffleAssert.eventEmitted(result, 'GameDraw', (ev) => {
        return  ev.player1 == player1 && ev.player2 == player2;
   },  'GameDraw should be emitted 2 players (address of player1 and player 2)');
    })


})
