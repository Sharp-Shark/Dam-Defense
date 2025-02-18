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
	commandElectionErrorAlreadyOngoing = 'Cannot start an election because one is already ongoing.',
	commandElectionErrorMainEvent = 'Cannot start an election because a main event is ongoing.',
	commandElectionErrorLimitReached = 'Limit reached! You cannot start more than one election per round.',
	commandElectionErrorNoCaptain = 'Cannot start an election because there is no captain.',
	commandElectionErrorNoSecurity = 'Cannot start an election because there is no security member aside from the captain.',
	huskInfo = 'You have become a husk! Try and spread the infection to other players, thusly turning everyone into a husk. You can hold ragdoll to regenerate.',
	undeadInfo = 'You have become an undead! Try and help the blood cult by killing nonbelievers and following cultists. You can hold ragdoll to regenerate.',
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
	gangWarGangsterInfo = 'You are a gang member of the {gangName}. Your sole objective is to eliminate the rival gang, known as {rivalGangName}. You have {timer} until everyone becomes aware of the gang war. Your gang may try and ally itself with the proletariat and security alike to gain an edge. Beware security gets a reward for arresting gangsters. Your pay grade has been raised. Do /gang for a list of fellow and known gangsters.',
	gangWarGangsterReveal = 'Everyone is now aware there are two rival gangs in the area, but they do not know who the gangsters are yet. Keep your cool, wise guy!',
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
	-- wiki misc
	wiki_description = 'Description: {description}\n\n',
	-- wiki main
	wikiName_main = 'Dam Defense',
	wikiText_main = 'Dam Defense is a mod for the Sandbox mode inspired by SS13 with focus on light RP. Adds custom creatures, items, jobs, maps/submarines, machines and lua scripts.\nLong live Tchernobog!\n\nThis wiki is still a work-in-progress. If you wish to help improve it, join the discord: ' .. DD.discordInvite .. '\n\nDo "/help" in chat for a list of commands!',
	wikiName_openhtml = 'Browser Wiki',
	wikiText_openhtml = 'You are not supposed to be reading this! Please report this bug on the discord.',
	wikiName_events = 'Events',
	wikiText_events = 'In the Dam Defense mod there are several in-game events powered by Lua scripts, which are chosen semi-randomly on a set timer. Events are sorted into 2 categories, Main Events and Side Events. Main events disable respawning while they are happening, usually have some sort of inherent round ending capability and there can only be one main event at a time. Meanwhile, side events do not disable respawning, do not have any way to end the round by themselves and there can be many side events happening at the same time.\n\nThat was the short explanation, which should suffice for 99% of players, but if you are one of the few more inquisitive players, here is a longer and slightly technical explanation: there is an Event Director which knows a list of events. Events have multiple properties relevant to the Event Director, such as if they are main events (there can only be one main event at a time), the maximun instances of that event that can exist at any one time, for how much time no other events will be started when this one starts (cooldown) and the "goodness" of the event (Event Director will try to not do too keep a balance of disruptive and beneficial events).\nAdditionally, there is a event cooldown timer specifically for side events and one for main events. Side events do not interfer with the main event timer, but the main event timer will reset the side event timer. The side event timer will start elapsing as soon as a side event is started, but the main event timer will only start elapsing if there are no ongoing main events.',
	wikiName_jobs = 'Jobs',
	wikiText_jobs = 'Dam Defense has quite a few jobs. Some of them you can choose to spawn as, some are related to an event, and only come into play when the pertinent event occurs. Part of the jobs are antag safe, meaning they can never become antagonists in an event, others are not. Security jobs are always antag safe and are tasked with weeding out antagonists and keeping the dam secure. The mayor is capable of firing any and all members of security using the "/fire" command.',
	wikiName_items = 'Items',
	wikiText_items = 'Lamp Oil, Rope, Bombs? You want it? It is yours, my friend. As long as you have enough rupees. ',
	wikiName_creatures = 'Creatures',
	wikiText_creatures = 'Goblins, undead, insects, creepy crawlies, infected, monsters and animals.\n\nThis page links to creatures added by Dam Defense or vanilla critters it modifies.',
	wikiName_medicalSystem = 'Medical System',
	wikiText_medicalSystem = 'Wait, wait, wait, it gets better. When the patient woke up, his skeleton was missing, and the doctor was never heard from again! Anyway, that is how I lost my medical license, heh.\n\nSaline treats gangrene. Cigar, pipe tabacco and crystal meth when smoken heal damage and bloodloss but cause pulmonary emphysema. Adrenaline, alcohol and rum gives an immune boost (the last two need to be drunk to give an immune boost). Stabilizone treats fever.\n\nThis page links to relevant afflictions and medical items from the Dam Defense mod.',
	wikiName_radiation = 'Radioactivity',
	wikiText_radiation = 'Spent fuel rods (the lower the condition, the more radioactive they are) and sky alien artifacts will glow an eerie blue color and emmit radiation, which will give nearby creatures radiation sickness. The brightness of the glow and the level of radioactivity are directly proportional.\nExosuits and artifact containers will fully shield the radiation whilst rapid fissile accelerators, reactors and being underwater will only partially block it. Wearing a hazmat suit, lead-lined overalls, diving suits or other clothing that have radiation sickness resistance is advised whenever handling or going near radioactive material.\nAntirad should be used to treat radiation sickness. It can be crafted with stabilizone, iron and carbon.',
	wikiName_dams = 'Dams (Maps)',
	wikiText_dams = 'Dam Defense has a selection of maps that come with the mod. What all of them have in common? They all have a dam, and you must (usually) protect that dam!',
	wikiName_placeholder = 'Lorem Ipsum',
	wikiText_placeholder = 'Lorem ipsum dolor sit amet.',
	-- wiki main events
	wikiName_nukiesEvent = 'Nukies Event',
	wikiText_nukiesEvent = 'A main event where several Jovian Elite Troopers (abbreviated: JET or Nukies) attempt to siege the dam and blow up its reactor or kill all employees to claim victory. JETs spawn high up on a cliff at the right of the dam basin, in a room with a bunch of Nukie Vending Machines. They Spawn with 50 counterfeit nexcredits to spend at their vending machines to buy weaponry, supplies, and equipment. All Nukies spawn with plasma cutters, armor, a diving mask with oxygen, a combat stim autoinjector and a powerful Antique Revolver.\nNote that the reactor is immune to explosions, meaning to destroy it, the Nukies must cause it to meltdown. It is imperative for all to protect the reactor when this event occurs because if the Nukies do cause a meltdown, the round will immediately end and victory will be given to them.',
	wikiName_serialKillerEvent = 'Serial Killer Event',
	wikiText_serialKillerEvent = 'A main event, where one person without an antag-safe job is randomly chosen to be the Serial Killer (abbreviated: SK). They win once they have killed enough players, but they will be periodically be assigned a specific target that if they kill, will reset their time pressure and award them with 5 Nexcredits.\nWhen the person is chosen, they are told they will turn into the SK in one (1) minute, to give them time to prepare and isolate themselves, as when the timer is up a Creepy Mask will be automatically placed on their face.\nThis mask can be taken off, but when worn, the mask provides the Blood Lust effect. This affliction increases run speed, melee stun and damage, provides quick passive regeneration, grants a 35% damage resistance and makes the user immune to oxygen loss. However, the mask does not give any resistances to fire, making the SK weak to it. The SK has a three (3) times damage and stun multiplier to his melee attacks, making him dangerous in melee combat and deadly if you are alone. The Creepy Mask also provides the wearer with thermal vision, allowing him to see people and creatures through walls.\nThe SK can also at all times hear the text messages of any dead players, letting him communicate with them to find survivors or for other information if they are willing to collaborate with you (note that as an SK you should generally use text chat to communicate with ghosts as they an always see the text pop up, unlike voice chat which is dependent on where they are spectating).\nAnyone who is not the SK who wears the Creepy Mask will instantly have their head explode.',
	wikiName_revolutionEvent = 'Revolution Event',
	wikiText_revolutionEvent = 'A main event where a few players without an antag-safe job are randomly chosen to be the leaders of a revolution. The rebel leaders win once all of security (which includes the head engineer, the security officers, the diver and the captain) are killed. Rebels leaders should not kill anyone else but instead recruit them to their fight for freedom.\n Rebel leaders can craft Separatist Rifles, Marksman Rifles, Separatist Body Armor and Separatist Rifle Magazines, all powerful and cheap items for combat.\nInitially no one knows who the rebel leaders are but themselves (if you forget who your comrades are, do "/rebels"), but eventually, after about 10 minutes, Nexpharma will uncover all the rebel leaders to everyone (if you forget who the rebel leaders are, do "/rebels"). As such, it is imperative that rebel leaders take benefit of this window of opportunity where their affiliation is still secret.',
	wikiName_gangWarEvent = 'Gang War Event',
	wikiText_gangWarEvent = 'A main event where a few players without an antag-safe job are randomly chosen to be part of one out of two rival gangs. A gang wins once it has eliminated all the members of the enemy gang, and they do not need kill anyone else to win, although they still often do. Security can win this event by arresting all of the gang members and will be rewarded well for doing so, but they can also instead be neutral or even ally themselves with a gang.\nGang members can craft crystal meth and spray cans of their respective gang color, UZIs and ballistic backwards cap (a stylish helmet). Commoners can join a gang by smoking crystal meth out of a captains pipe.\nAs time passes, the Nexpharma equivalent to the IRS will uncover who the gangsters are. Medical can also work with security to see if someone is a gang member by using blood samplers; whoever returns positive on the crystal meth test is a gang member.\nIt is important to note that if a gang wins this event, the round will not end.',
	wikiName_bloodCultEvent = 'Blood Cult Event',
	wikiText_bloodCultEvent = 'A main event where a few players without an antag-safe job are randomly chosen to be part of a blood cult. The blood cult wins once there are no non-cultists alive. This can achieved either by killing the heretics or by converting them into their fatih. To do the latter, the cultist will need to whack the nonbeliever with "The 1998" book a few times. Doing so will also reset the time pressure of all cultists.\n Aside from the book, cultists can also craft a Blood Cultist Robe and a Sacrificial Dagger. The robe can only be worn by cultists and provides regeneration. Additionally if a cultist dies whilst wearing the robe, he will come back to life as an undead. The sacrificial dagger can be used on anyone on a critical health state or who has died less than 15 seconds ago. Doing so, will extract their life essence.\nLife essence can be consumed to reset the time pressure of the user and to heal them, or it can be put inside a sacrificial dagger or the book to make them stronger.\nThe unfaithful are unable to tell who is and who is not a cultist, but the cultists can know who their kin is by using the chat command "/cultists". Additionally, cultists can also secretly and remotely communicate with their brothers via telepathy with the "/whisper" command.\nAt the start of the event, an airdrop with cultist items will also be dropped at the slums.',
	wikiName_deathSquadEvent = 'Death Squad Event',
	wikiText_deathSquadEvent = 'A main event like the regular MERCS event but with one key difference, that being instead of the MERCS trying to help the employees of the Dam, they are trying to kill everyone inside the dam or explode the reactor. The Deathsquad spawns in the same place that the MERCS do and look nearly identical to them, even their arrival text appear to be the same as a normal MERCS event to any employees. They are incredibly dangerous and powerful and will more than likely eradicate all employees they encounter unless severely outnumbered. The fact that they also have the advantage of deception and surprise makes them even more dangerous. Make sure you as a death squad member do not accidentally think you are part of the normal MERCS squad and vice versa.',
	wikiName_greenskinsEvent = 'Greenskins Event',
	wikiText_greenskinsEvent = 'A main event where all dead players respawn as Goblins and Trolls in the sewers of the town. Note that this event does not have an associated announcement to go with it and it can very easily catch you by surprise. Always be wary for sightings of goblins.\nBoth Goblins and Trolls appear as green hairless humanoids wearing green clown masks. They are immune to all forms of stun, move swiftly in water, explode upon death, and can also put masks on both living and dead humans to instantly convert them into a greenskin. Goblins are weaker and smaller than humans, but are faster than them, making them effective hit and run fighters when they have stun capability. Trolls, however are slower, tankier and dumber, being unable to use any items, but to compensate have a very powerful melee attack.\nGreenskins spawn with midazolam, methamphetamine, a few goblin masks, and eight (8) goblin crates. Goblins and Trolls can drop goblin crates on the ground to both hide inside of and also heal themselves of regular damage. Midazolam instantly heals and stuns, for more information view its wiki page.',
	-- wiki side events
	wikiName_airdropEvent = 'Airdrop Event',
	wikiText_airdropEvent = 'This is a side event where a box of supplies is dropped onto one of three buildings, either the Prison, Hospital, or Factory. The contents of the supplies will change depending on where the box was dropped. For example the Prison airdrop will contain ammunition. Some airdrop events can only occur in tandem with main events, like the illicit airdrops that happen over the Slums at the start of the Blood Cult and Revolution events.\nThere is another different kind of airdrop event: the artifact airdrop event, where a dangerous alien artifact will fall on a random place in the map. Adventurous players can try to deconstruct these artifact for rare otherwise unobtainable alien materials, which can be used to craft powerful experimental equipment, medicine and weapons.',
	wikiName_fishEvent = 'Fish Event',
	wikiText_fishEvent = 'This is a side event that can spawn a variety of monsters either in the dam basin or in the sewers under the town. Monsters will always be of the same type for each individual event, and can either be: Crawler Hatchlings, Mudraptor Hatchlings, Tiger Thresher Hatchlings, Spitroach hatchlings, or most rare, Husks.\nMost creatures have growth stages, where over time they grow in size from hatchlings to larger varieties and, when mature, lay eggs which will spawn more hatchlings. For this reason it is recommended to deal with monsters as early as you can. Mudraptors in particular can be dangerous if enough of them evolve to Veteran Mudraptors.',
	wikiName_murderEvent = 'Murder Event',
	wikiText_murderEvent = 'This is a side event where one non antag safe person is randomly selected to be the Murderer, and another non security member player is selected to be the Victim. Upon successfully murdering the Victim, the Murderer will have a large sum of Nexcredits deposited into their Nexbank, and Security will be alerted that they are after an unknown suspect who committed manslaughter, regardless of how many people saw you murder the target. There are two fail conditions for the murderer, either being killed or being put in cuffs. If they are cuffed, Security is paid for the arrest and the Murderer will no longer have a victim, and thus cease to be a Murderer. If the Murderer is killed, Security is not paid but next respawn the Murderer will no longer be a Murderer.',
	wikiName_arrestEvent = 'Arrest Event',
	wikiText_arrestEvent = 'This is a side event where an non antag safe person is randomly chosen to be the Criminal, where a random crime is given to them. Security will be collectively paid as soon as the Criminal is put in cuffs. The criminal is not awarded for evading arrest, other than sometimes potentially avoiding jail time (although usually security will catch and immediately release), however they are fully allowed to run and pursue hijinks if they wish so.',
	wikiName_afflictionEvent = 'Outbreak Event',
	wikiText_afflictionEvent = 'This is a side event where one out of a few different diseases will be given to a random selection of players. There are some checks in place to make sure the initial infected make sense, so for example, someone breathing out from an oxygen tank will never be a patient zero in an influenza outbreak.',
	wikiName_blackoutEvent = 'Blackout Event',
	wikiText_blackoutEvent = 'This is a side event where all lights in the map turn off and every door connected to buttons opens. All other objects that require power, like pumps and fabricators, will be unaffected though. This can pose serious security risks to the dam if happening in tandem with a main event.',
	wikiName_vipEvent = 'VIP Event',
	wikiText_vipEvent = 'This is a side event where a random non security player is chosen to become a VIP and a player is spawned in as their bodyguard. The VIP and bodyguard earn both a hefty salary for staying alive. The bodyguard must keep the VIP alive at all costs. Failure will result in immediate termination via explosive brain implant. Any non security member who kills the VIP will be awarded a big cash prize.',
	wikiName_mercsEvent = 'MERCS Event',
	wikiText_mercsEvent = 'This is a side event where a player will be spawned as a member of the Mobile Emergency Rescue and Combat Squad (abbreviated: MERCS). Their goal is to assist security and they are essentially a super cop, even counting as a member of security. They look very similar to the Death Squadders, but have an entirely different objective.',
	wikiName_electionEvent = 'Election Event',
	wikiText_electionEvent = 'This is a side event where you can vote yes to replace the current captain or vote no to keep him! Head to your nearest ballot box, insert your desired amount of Nexcredits (TM) and press "Vote Yes" or "Vote No". Each player once per round can start an election event if there is no ongoing main event or election event by doing "/election".',
	wikiName_withdrawEvent = 'Withdraw Event',
	wikiText_withdrawEvent = 'Whenever money is withdrawn, this event is responsible for spawning the Nexcase and the Nexcredits inside and then, later, despawning the Nexcase to avoid clutter. You can withdraw credits using "/withdraw" or clicking the "Withdraw" button. You can check your bank balance using "/credits".',
	-- wiki jobs
	wikiName_captainJob = 'Mayor',
	wikiText_captainJob = 'Antag safe job, a member of security. There can only be one mayor at a time. The mayor is capable of firing any and all members of security using the "/fire" command. The mayor may get replaced with another member of security depending on the result of an election. It is in his interest to always press "Vote No" on the ballot boxes, least he wants to be killed and become a lowly laborer.',
	wikiName_engineerJob = 'Engineer',
	wikiText_engineerJob = 'There can only be three engineers at a time.',
	wikiName_securityofficerJob = 'Enforcer',
	wikiText_securityofficerJob = 'Antag safe job, a member of security. There can only be two enforcers at a time. The mayor may get replaced with another member of security depending on the result of an election.',
	wikiName_medicaldoctorJob = 'Medical Doctor',
	wikiText_medicaldoctorJob = 'Antag safe job. There can only be one medical doctor at a time.',
	wikiName_assistantJob = 'Convict',
	wikiText_assistantJob = 'This job is not from any event and cannot be spawned as normally. Players who are job banned from all other jobs will spawn as a convict in the prison. Not fun to play as, mostly a punishment for griefers, although some lunatics ask admins to be job banned so they can play as a prisoner.',
	wikiName_mechanicJob = 'Laborer',
	wikiText_mechanicJob = 'The urban poor, experts in manufacturing. The amount of laborers is uncapped. Players who "late join" will be spawned as laborers.',
	wikiName_janitorJob = 'Janitor',
	wikiText_janitorJob = 'There can only be two janitors.',
	wikiName_clownJob = 'Clown',
	wikiText_clownJob = 'Honk! There can only be one master of chaos.',
	wikiName_foremanJob = 'Head Engineer',
	wikiText_foremanJob = 'Antag safe job, a member of security. There can only be one head engineer. The head engineer is sometimes called the foreman. The mayor may get replaced with another member of security depending on the result of an election.',
	wikiName_researcherJob = 'Researcher',
	wikiText_researcherJob = 'Antag safe job. There can only be one researcher.',
	wikiName_diverJob = 'Diver',
	wikiText_diverJob = 'Antag safe job, a member of security. There can only be one diver. The mayor may get replaced with another member of security depending on the result of an election.',
	wikiName_bodyguardJob = 'Bodyguard',
	wikiText_bodyguardJob = 'A neutral event job. Tasked with protecting the VIP. Failure results in their immediate termination via explosive brain implant.',
	wikiName_jetJob = 'Nukie',
	wikiText_jetJob = 'An antagonic event job. Their objective is to meltdown the reactor or to kill everyone, if they do one of these, they win and the round ends.',
	wikiName_mercsJob = 'MERCS Member',
	wikiText_mercsJob = 'An antag safe and also a member of security event job. They look very similar to Death Squadders, but unlike them, they are good.',
	wikiName_mercsevilJob = 'Death Squadder',
	wikiText_mercsevilJob = 'An antagonic event job. They look very similar to MERCS Members, but unlike them, they are evil.',
	-- wiki items
	wikiName_bacterialsyringeItem = 'Live Bacteria',
	wikiText_bacterialsyringeItem = 'A live sample of a generic bacterial infection taken with a blood sampler. Commonly found in gangrenous wounds. Can be processed into ABX.',
	wikiName_flusyringeItem = 'Live Influenza',
	wikiText_flusyringeItem = 'A live sample of influenza taken with a blood sampler. Occasional outbreaks are common, but usually no deaths occur. Can be processed into Influenza Antidote.',
	wikiName_tbsyringeItem = 'Live Tuberculosis',
	wikiText_tbsyringeItem = 'A live sample of tuberculosis taken with a blood sampler. Outbreaks are uncommon but not rare. Deadly infection. Can be processed into Tuberculosis Antidote or ABX.',
	wikiName_fluantidoteItem = 'Influenza Antidote',
	wikiText_fluantidoteItem = 'A serum for influenza, quickly curing the infection and providing short term immunity until the antibodies break down. This is not a vaccine and will not permanently immunize.',
	wikiName_tbantidoteItem = 'Tuberculosis Antidote',
	wikiText_tbantidoteItem = 'A serum for tuberculosis, quickly curing the infection and providing short term immunity until the antibodies break down. This is not a vaccine and will not permanently immunize.',
	wikiName_tbantidoteItem = 'Tuberculosis Antidote',
	wikiText_tbantidoteItem = 'A serum for tuberculosis, quickly curing the infection and providing short term immunity until the antibodies break down. This is not a vaccine and will not permanently immunize.',
	wikiName_myxotoxinItem = 'Myxotoxin',
	wikiText_myxotoxinItem = 'Myxotoxin extracted from a colony of Myxobacteria, coloquially referred to as Slime Bacteria, a species commonly found growing in the region. It is commonly used by the poor as an alternative to ABX that they cannot afford, but is less effective. Can be processed and concentrated into proper ABX.',
	wikiName_midazolamItem = 'Midazolam',
	wikiText_midazolamItem =  'A medical item that when used, greatly heals damage and slightly treats burns, but also instantly stuns and slightly drunkens. It can be crafted in a medical fabricator using chloral hydrate, tonic liquid and ethanol. It does not require too much medical skill or time to craft either. It can be used both to quickly heal an ally, at the downside of stunning them briefly, or on an enemy, by playing into the stun to do tactical plays whilst they are unconcious. Bodyguards (VIP Event), MERCS (MERCS and Death Squad Event), Goblins and Trolls (Greenskin Event) all spawn with this item.',
	wikiName_bloodsamplerItem = 'Blood Sampler',
	wikiText_bloodsamplerItem = 'Can be used on people to test them for diseases and for crystal meth (positive on crystal meth indicates player is a gang member, relevant to Gang War Event). Non medical jobs will have their test results partially randomized, so only doctors can fully utilize this item to this end. Can also be used by anyone to take live samples of diseases from infected individuals if their infectious load is high enough. Live samples can usually be used to make antidotes... or for bioterrorism.',
	wikiName_brassknuckleItem = 'Brass Knuckle',
	wikiText_brassknuckleItem = 'Made of actual brass, this one-handed melee weapon, when equipped two of them, one in each hand, has a decent attack rate and blunt damage. Whenever you hit the hand of another player, regardless of whether you are dual-wielding the brass knuckles or not, whatever item that hand is holding will be dropped (unless the item is a brass knuckle). If you act swiftly, you can grab the dropped weapon off the floor and kill your foe with their own gun. Quite humiliating!',
	wikiName_printerItem = 'Printer',
	wikiText_printerItem = 'A machine found in the office of the mayor that takes in plastic, organic fiber, ID cards and clothing. Useful for manufacturing new blank ID cards or clothing (fabricate), deconstructing them into their raw materials (deconstruct) or upgrading/downgrading an ID card (apply job).\nOrganic fiber can be fabricated into clothing, which when deconstructed will wield organic fiber back without loss. The same applies to plastic and ID cards. This is all done instantly and does not require power.\nCuriously, it can be used to obtain some usually non-accessible clothing or ID cards. This is done by typing in "shop", "miner", "vip", "admin" or "cultist" and clicking the "apply" button on an ID card or piece of clothing. The "vip", "admin" and "cultist" only work on clothing and do nothing to ID cards.\n\nTip: in the text box, type in "name:John Doe" and when you click apply, the ID card will say John Doe is its owner. This is useful for making ID cards that actually identify the wearer to onlookers. You can also apply a job and rename an ID card at the same time by typing something like "clown,name:Joe Clown" in the text box and applying.',
	-- wiki creatures
	wikiName_spitroachCreature = 'Spitroach',
	wikiText_spitroachCreature = 'An annoying cowardly pest that breeds and grows fast. They run up close, spit their acid, run away and repeat, usually in a synchronized group motion. When no targets are in sight, they spit on their walls, causing leaks and trouble.',
	wikiName_huskCreature = 'Husks',
	wikiText_huskCreature = 'A diver infected with the Velonaceps Calyx parasite. Contagious and disruptive enemies capable of ending rounds by themselves occasionally due to their infectious nature. After some time has elapsed they will grow into husk prowlers, a stronger and more savage form.',
	wikiName_greenskinCreature = 'Greenskins',
	wikiText_greenskinCreature = 'Both Goblins and Trolls appear as green hairless humanoids wearing green clown masks. They are immune to all forms of stun, move swiftly in water, explode upon death, and can also put masks on both living and dead humans to instantly convert them into a greenskin. Goblins are weaker and smaller than humans, but are faster than them, making them effective hit and run fighters when they have stun capability. Trolls, however are slower, tankier and dumber, being unable to use any items, but to compensate have a very powerful melee attack.\nGreenskins spawn with midazolam, methamphetamine, a few goblin masks, and eight (8) goblin crates. Goblins and Trolls can drop goblin crates on the ground to both hide inside of and also heal themselves of regular damage. Midazolam instantly heals and stuns, for more information view its wiki page.',
	-- wiki afflictions
	wikiName_bacterialinfectionAffliction = 'Bacterial Infection',
	wikiText_bacterialinfectionAffliction = 'Non contagious disease, usually acquired when a gangrenous wound is not treated and the infection spreads to the body. Sepsis is lethal in most cases when ignored. Can be treated with ABX or Myxotoxin from a colony of Myxobacteria. Fever can be treated with stabilizone if necessary.',
	wikiName_influenzainfectionAffliction = 'Influenza Infection',
	wikiText_influenzainfectionAffliction = 'Highly contagious disease. Only very rarely kills and goes away on its own. Anything that boosts the immune response will speed up recovery. Best treatment is rest and possibly stabilizone if the fever gets too intense. Influenza Antidote can immediately cure the infection. Avoid smoking whilst infected.',
	wikiName_tbinfectionAffliction = 'Tuberculosis Infection',
	wikiText_tbinfectionAffliction = 'Tuberculosis also known as the White Death is a highly contagious bacterial infection which almost always leads to death if not treated. Can be treated with ABX or Myxotoxin from a colony of Myxobacteria or cured using Tuberculosis Antidote. Will cause or aggravate a pulmonary emphysema.',
	-- wiki dams (maps)
	wikiName_oldeTowneDam = 'Olde Towne',
	wikiText_oldeTowneDam = 'The original first Dam Defense map. An old dam with a small but well-established industrial colony to its left. The basin is mostly open, with only a small but still cave system with wide passages. Despite its age, most of the ore in the basin have yet to be mined.\n\nMap by Sharp-Shark.',
	wikiName_pioneerPointDam = 'Pioneer Point',
	wikiText_pioneerPointDam = 'The second Dam Defense map, made for smaller player counts and with a focus on verticality. A dam still in construction with a tiny pioneer settlement, eager to explore this land on the edge of civilization. The basin consists entirely out of a narrow cave system.\n\nMap by Sharp-Shark.',
	-- end
	[''] = '',
}