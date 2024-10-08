-- english localization by Sharp-Shark
return {
	-- main.lua
	matchHasGoneOnForTooLong = 'The match has gone on for too long and respawning has been automatically disabled.',
	allTheCrewIsDead = 'All of the crew is dead! Round ending in 10 seconds.',
	commandHelp = 'List of chat commands:\n{list}.',
	commandHelpMisspell = '"{command}" is not a valid chat command. Do "/help" for a list of chat commands.',
	commandInfoMonster = 'You are a monster and your objective is to antagonize the humans.',
	commandPossessErrorDead = 'You have to be dead to use this command.',
	commandPossessErrorNothingNearby = 'No nearby character fit to be possessed was found.',
	commandPossess = 'Do /freecam to go back to spectating. You cannot respawn unless you are spectating.',
	commandFreecamErrorDead = 'You are already spectating.',
	commandFreecamErrorHuman = 'You cannot become a spectator whilst controlling a human.',
	commandFire = 'The captain has decided to fire {name} from the security force!',
	commandFireAdmin = 'Nexpharma (TM) has decided to fire {name} from the security force!',
	huskInfo = 'You have become a husk! Try and spread the infection to other players, thusly turning everyone into a husk. You can hold ragdoll to regenerate.',
	-- eventDirector.lua
	commandEventsNone = 'none (there are no public events)',
	commandEvents = 'The public list of events currently is: {list}.',
	commandMyEventsNone = 'none (you are in no events)',
	commandMyEvents = 'The events you are currently in are: {list}.',
	-- latejoin.lua
	lateJoinMessage = 'Respawning is currently disabled, however you and anyone who just joined will be spawned in as a laborer within {timer}.',
	lateJoinAnnounceTimer = 'Late-join spawn will occur within {timer}.',
	-- money.lua
	giveMoneyToClient = 'You have received {amount} Nexcredits (TM).',
	commandCreditsError = 'You have no Nexaccount (TM).',
	commandCredits = 'You have {amount} Nexcredits (TM) in your Nexaccount (TM). Your next reward will be in {timer}.',
	commandWithdrawError = 'You have no Nexaccount (TM).',
	commandWithdrawErrorDead = 'You have to be alive to withdraw.',
	commandWithdrawErrorNotHuman = 'Error! Non-human lifeform detected.',
	commandWithdrawErrorCooldown = 'You have to wait {timer} before you can withdraw again.',
	commandWithdrawErrorInvalidAmount = 'You have tried to withdraw an invalid amount and thusly failed. Do "/credits" to see how many credits you have.',
	commandWithdraw = 'A Nexcase (TM) with {amount} Nexcredits (TM) has been teleported to you by Nexmail (TM). It will be teleported back in {seconds} seconds along with anything left inside!',
	-- events/affliction.lua (TBD)
	-- events/airdrop.lua (TBD)
	-- events/arrest.lua (TBD)
	-- events/blackout.lua (TBD)
	-- events/bloodCult.lua (TBD)
	bloodCultRecruitmentNotice = 'The cult has just recruited {name}!',
	-- events/election.lua
	electionStart = 'Time for democracy, vote yes to replace the current captain, vote no to keep him! Head to your nearest ballot box, insert your desired amount of Nexcredits (TM) and press "Vote Yes" or "Vote No". You have {timer} to vote with your wallet!',
	electionVoteCast = 'New votes have been cast!',
	electionEndYes = 'The election has ended and it has been democratically decided to replace the current captain with a new one! The new captain is {name}.',
	electionEndYesFail = 'The election has ended and it has been democratically decided to replace the current captain with a new one, however due to a lack of a proper replacement, the decision will sadly be ignored.',
	electionEndNo = 'The election has ended and it has been democratically decided to keep the current captain!',
	electionEndFail = 'The election has ended because the captain has died or some other failure in the process.',
	-- events/fish.lua (TBD)
	-- events/gangWar.lua (still need to add localization for "/gang")
	gangWarDoxx = 'The Nexbank (TM) has found unusual activity in the account of {name}, and as such has determined they are a gang member. Do /gang to get the public list of gang members.',
	gangWarGangsterInfo = 'You are a gang member of the {gangName}. Your sole objective is to eliminate the rival gang, known as {rivalGangName}. Your gang may try and ally itself with the proletariat and security alike to gain an edge. Beware security gets a reward for arresting gangsters. Your pay grade has been raised. Do /gang for a list of fellow and known gangsters.',
	gangWarSecurityInfo = 'Two rival gangs are in the area. Their objective does not involve destroying the dam, however they may still cause havoc in the process of eliminating their rivals. Security will be rewarded at event end 5 nexcredits per arrested gangster. Despite that, you may try and stay neutral, or even ally yourself with one of the gangs. Do /gang for a list of known gangsters.',
	gangWarCommonerInfo = 'Two rival gangs are in the area. Their objective does not involve destroying the dam, however they may still cause havoc in the process of eliminating their rivals. You may try and stay neutral, or even ally yourself with one of the gangs. Do /gang for a list of known gangsters.',
	gangWarEndGang = 'The {gangName} has won agaisnt the {rivalGangName}! Life goes on.',
	gangWarEndSecurity = 'Both gangs have been arrested and security has been promptly rewarded! Life goes on.',
	gangWarEndNeutral = 'Both gangs have been eliminated! Life goes on.',
	gangWarRecruitmentNotice = 'Your gang has just recruited {name}!',
	-- events/ghostRole.lua (TBD)
	-- events/greenskins.lua
	greenskinInfo = 'You are a kind of amphibious nimble critter that like playing games with their prey. Put masks on humans to turn them into goblins. Hide in goblin crates to regenerate.',
	greenskinsEventEndDefeat = 'All greenskins have been eliminated.',
	-- events/murder.lua (TBD)
	-- events/nukies.lua (TBD)
	-- events/revolution.lua (TBD)
	-- events/serialKiller.lua (TBD)
	-- end
	[''] = '',
}