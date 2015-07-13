function ArthasPhaseThink_1( boss )
end

function ArthasPhaseThink_2( boss )
end

function ArthasPhaseThink_3( boss )
end

function OnEnterPhase_1( boss )

end

function OnEnterPhase_2( boss )
end

function OnEnterPhase_3( boss )
end

function OnEnterPhase_4( boss )
end

function ArthasAIThink( boss )
	if not IsValidEntity(boss) then
		return nil
	end
	if not boss:IsAlive() then
		-- TODO : fire game events to tell arthas was killed
		return nil
	end

	if boss.__fsm__:get() ~= "AIBASIC_STATE_fighting" then
		return 0.1
	end

	-- 基于血量的状态转换
	local hp = boss:GetHealth() / boss:GetMaxHealth()
	local function SetPhase( phase )
		if boss.currentPhase ~= phase then
			if _G["OnEnterPhase_" .. phase ] then _G["OnEnterPhase_" .. phase ](boss) end
			boss.currentPhase = phase
		end
	end
	if hp >= 0.7 and hp < 1 then 	SetPhase( 1 ) end
	if hp >= 0.4 and hp < 0.7 then 	SetPhase( 2 ) end
	if hp >= 0.1 and hp < 0.4 then 	SetPhase( 3 ) end
	if hp < 0.1 then 			SetPhase( 4 ) end

	local think = _G["ArthasPhaseThink_" .. boss.currentPhase]

	if think then return think( boss ) end

	return 0.1
end

CBossManager:RegisterBoss("boss_arthas", true ) -- boss name, is playable, give nil if it's not playable

require("ai.ai_basic")

function Spawn(kv)
	print("BossArthas spawned, ->", thisEntity)
	AIBASIC_InternalSpawn( thisEntity )
	thisEntity.currentPhase = 0
	thisEntity:SetContextThink(DoUniqueString("arthas_ai"), function() return ArthasAIThink( thisEntity ) end, 0)
end

--[[
init = function( boss , difficulty)

		-- 初始化BOSS数据
		boss.data = {}

		-- 阶段1技能 phase1
		boss.Ability_call_xuejiangshi = boss:FindAbilityByName("arthas_call_xuejiangshi") -- 召唤蹒跚的血僵尸 1
		boss.Ability_call_shishigui = boss:FindAbilityByName("arthas_call_shishigui") -- 召唤食尸鬼苦工 2
		boss.Ability_siqu = boss:FindAbilityByName("arthas_siqu") -- 死疽 3

		-- 转阶段阶段技能 phase1-2 phase2-3
		boss.Ability_lengku_handong = boss:FindAbilityByName("arthas_lengku_handong") -- 冷酷寒冬 4
		boss.Ability_baoshouzhemo = boss:FindAbilityByName("arthas_baoshouzhemo") -- 饱受折磨 5
		boss.Ability_call_hanbingqiuti = boss:FindAbilityByName("arthas_call_hanbingqiuti") -- 召唤寒冰球体 6
		boss.Ability_call_kuangnuguihun = boss:FindAbilityByName("arthas_call_kuangnuguihun") -- 召唤狂怒鬼魂 7

		-- 阶段2技能 phase2
		boss.Ability_jisheng = boss:FindAbilityByName("arthas_jisheng") -- 寄生 8
		boss.Ability_linghunshouge = boss:FindAbilityByName("arthas_linghunshouge") -- 灵魂收割 9
		boss.Ability_wuran = boss:FindAbilityByName("arthas_wuran") -- 污染 10
		boss.Ability_call_huaerqi = boss:FindAbilityByName("arthas_call_huaerqi") -- 召唤华尔琪 11

		-- 阶段3技能 phase 3
		boss.Ability_shougelinghun = boss:FindAbilityByName("arthas_shougelinghun") -- 收割灵魂 12
		boss.Ability_call_beilielinghun = boss:FindAbilityByName("arthas_call_beilielinghun") -- 召唤卑劣灵魂 13

		boss.FSM = {}
		local CFSM = require("ai.fsm")
		boss.FSM.n = CFSM:new(boss, {
			{"waiting","on_boss_get_hurt","phase1",OnFightStart}, -- 当受到伤害则触发进入战斗
			{"*","on_health_below_70","phase12",OnEnterPhase12},  -- 当血量低于70%转入阶段1-2过渡
			{"phase12","on_time_limit","phase2",OnEnterPhase2},   -- 阶段1-2过渡，当时间结束转入阶段2
			{"*","on_health_below_40","phase23",OnEnterPhase23},  -- 当血量低于40%转入阶段23
			{"phase23","on_time_limit","phase3",OnEnterPhase3},   -- 阶段2-3过渡，当时间结束转入阶段3
			{"*","on_health_below_10","end",OnEnd}				  -- 血量低于10%，战斗结束
		})
		boss.FSM.h = boss.FSM.n
		boss.fsm = boss.FSM[difficulty]

		boss:SetContextThink(DoUniqueString("boss_ai"), function()
			CheckBossState( boss ) -- 检测状态，脱离战斗区域，死亡等
			return AI[difficulty][boss.FSM[difficulty]:get()] ( boss ) or 0.1
		end, 0) --  start boss ai think
	end
--]]

--[[
整体流程
第一阶段（100%-70%），场上小怪杨：蹒跚的血僵尸、食尸鬼苦工；关键技能死疽、寄生。
第一、二阶段转换（持续1分钟），场上小怪：狂怒的鬼魂、寒冰球体。
第二阶段（70%-40%），场上小怪：华尔琪影卫，关键技能污染、灵魂收割、寄生。
第二、三阶段阶段转换（持续1分钟），场上小怪：狂怒的鬼魂、寒冰球体。
第三阶段阶段（40%-10%），场上小怪卑劣的灵魂；关键技能污染、灵魂收割、收割灵魂、灵魂爆发。
第三阶段阶段霜之哀伤内部，场上小怪灵魂看守者，NPC泰瑞纳斯·米奈希尔，关键技能灵魂撕裂。
第一阶段（100%-70%）
开打前有1分钟左右的剧情对话，巫妖王在台阶正前方将提里奥·弗丁封入冰块后直接进入战斗。
巫妖王每60秒召唤1只蹒跚的血僵尸（召唤蹒跚的血僵尸），每20秒召唤3只食尸鬼苦工（召唤食尸鬼苦工）。
召唤蹒跚的血僵尸：巫妖王在15码范围内召唤一只蹒跚的血僵尸，此怪有一个爬出地面的动作。
召唤食尸鬼苦工：巫妖王在10码范围内连续3秒每秒召唤1只食尸鬼苦工。
食尸鬼苦工无特殊技能。蹒跚的血僵尸每20秒使用激怒强化自己，平时使用震荡波攻击玩家。
另外，巫妖王每22秒施放寄生对所有人造成伤害。每秒会造成的伤害会不断提高，生命值高于90%才能消除。
关键技能：巫妖王每30秒对一名玩家（坦除外）施放死疽DEBUFF，每5秒对宿主造成一次伤害，持续15秒。
应对方法：死疽属于疾病效果，可以驱散（别立即驱散）。中了瘟疫的玩家立即跑到恐兽的侧面，然后治疗解掉就可以。
DEBUFF每次弹跳为巫妖王迭加一层热病虹吸BUFF，持续时间30秒。
热病虹吸：每次死疽弹跳会为巫妖王迭加一层BUFF，提高2%物理伤害，持续30秒，最多可迭500层。
巫妖王生命值到达70%时停止对玩家的攻击，跑向场地中央。
第一、二阶段转换（持续1分钟）
巫妖王跑向场地中央使用冷酷严冬，持续1分钟。场上四跟石柱在冷酷严冬出现的第一时间被破坏，玩家跑去外围浮冰区躲避该法术。
冷酷严冬：巫妖王在场地中央启动法术，每秒对45码范围内所有人造成冷酷严冬伤害，持续1分钟。
巫妖王在场地中央不断施放饱受折磨，对锥形范围内所有玩家造成伤害。
饱受折磨：巫妖王在场地中央不断朝前方锥形范围内玩家射出黑色光线，造成伤害并留下DEBUFF，持续3秒，最多可迭5层。
巫妖王每隔数秒在身边召唤一颗寒冰球体，冰球碰到玩家会将10码内所有人击飞到平台外。
召唤寒冰球体：巫妖王召唤一颗寒冰球体，可能出现在10码范围内任意位置。
第一、二阶段转换期间巫妖王一共召唤3只狂怒的鬼魂(狂怒的鬼魂)，刚开始召唤1只，中间召唤1只，临近结束时召唤1只。
狂怒的鬼魂使用灵魂尖啸对前方锥形范围内所有人造成伤害，附带沉默效果。
灵魂尖啸：狂怒的鬼魂对前方锥形范围内所有人造成大量伤害，附带一个可驱散的沉默DEBUFF，持续5秒。
冷酷严冬的1分钟时间到，巫妖王开始引导地震使外围浮冰区塌陷，阶段转换结束。
第二阶段（70%-40%）
浮冰区塌陷后战斗进入第二阶段，巫妖王每22秒施放一次寄生对所有人造成伤害。
巫妖王每30秒对仇恨目标使用一次灵魂收割。
灵魂收割：巫妖王首先对仇恨目标造成大小为武器伤害的50%，该伤害可被吸收、减免或抵抗。
关键技能：巫妖王每32秒对一名玩家施放污染，目标玩家所在位置出现一滩黑水，45秒后消失。
如果黑水范围内有玩家存在，则玩家每秒受到污染伤害，同时每跳伤害使黑水范围扩大一次。下面是处理方法：

关键技能：巫妖王每45秒就回召唤华尔琪影卫，每只华尔琪影卫随机抓起一名玩家飞向距离最近的平台边缘。10人模式下一次召唤1只，25人模式下一次召唤3只。
华尔琪影卫抵达平台边缘将手中玩家扔出去导致玩家死亡，其他人在此之前要将华尔琪影卫击杀以解救队友。
华尔琪影卫只受减速和昏迷效果影响，不受定身效果影响，同时华尔琪影卫拥有诅咒之翼BUFF。
诅咒之翼：华尔琪影卫的常驻BUFF，玩家的减速效果最多只能将华尔琪影卫的移动速度减至50%。
巫妖王生命值到达40%时停止对玩家的攻击，再次跑向场地中央。
第二、三阶段转换（持续1分钟）
重复第一、二阶段转换流程，处理好鬼魂和寒冰球体，胜利就在前方了。
第三阶段（40%-10%）
浮冰区再次塌陷进入第三阶段。巫妖王每30秒对仇恨目标使用一次灵魂收割。另外，第三阶段依然会出现污染。
巫妖王每30秒召唤10只卑劣的灵魂。卑劣的灵魂在空中停留15秒。
卑劣的灵魂：灵魂在空中停留时无仇恨，15秒后向各自仇恨目标飞去，途中碰到玩家会范围爆炸。
巫妖王每75秒对一名玩家（仇恨目标除外）使用收割灵魂，存活下来的玩家被传送到霜之哀伤内部。
收割灵魂：巫妖王强制一名玩家进入昏迷状态，每秒造成伤害，持续6秒。若玩家死亡则巫妖王获得一层割取的灵魂BUFF，否则玩家被传送到霜之哀伤内部。
收割灵魂：玩家死在收割灵魂过程中，或者死在霜之哀伤内部，则巫妖王的伤害提高100%，持续15秒。
巫妖王生命值到达10%时施放霜之哀伤的愤怒强制杀死所有人，实际上玩家此时已经获得胜利。10%以后是剧情阶段，玩家与提里奥·弗丁一同送巫妖王上路。
第三阶段：霜之哀伤内部
在收割灵魂伤害下存活的玩家被传送到霜之哀伤内部，首先获得一个收割灵魂DEBUFF。
收割灵魂：玩家进入霜之哀伤获得的DEBUFF，玩家要在1分钟内离开，否则直接死亡。
霜之哀伤内部是一块封闭的圆形区域，场地中央有一只灵魂看守者正在与老国王泰瑞纳斯·米奈希尔作战。

灵魂看守者身上有一个黑暗饥寒BUFF，每隔一段时间施放一次夺魂对老国王造成巨大伤害。
应对方法：玩家可以将老国王的生命值补满或者协助他一起攻击灵魂看守者，同时尽量打断灵魂撕裂。
这里治疗职业被点进剑里后，设看守者为焦点，然后狠刷国王，怪读条后立即打断（变熊拍晕，脚踩，制裁都可以），国王血满了，怪自然就死了。
击杀流程
与弗丁对话之后即可开启与巫妖王之间的战斗，一开始巫妖王和弗丁会喷口水，在巫妖王将弗丁冰冻住之后即进入正式的战斗。
第一阶段（100%-70%）
在第一阶段中，巫妖王会召唤食尸鬼苦工和蹣跚的恐兽与玩家作战。这里必须要有两个坦克，主坦克负责坦克巫妖王和食尸鬼苦工，副坦克负责坦克蹣跚的恐兽。

食尸鬼苦工每20秒会召唤一波，一波有三只食尸鬼苦工，食尸鬼伤害还低，主坦可以连王一起拉住，近战们稍微带着A掉就可以了。
恐兽每1分钟会召唤一只，外型是维酷人的样子，会从地上缓缓爬起，副坦接住，并且将其坦在巫妖王的附近，DPS职业在副坦克建立好仇恨后就可以对蹣跚的恐兽攻击，要能在下一只蹣跚的恐兽刷出之前将其杀掉。
第一阶段需要注意的地方：
1.恐兽会有个正面锥形20码的范围技（伤害很高），所以副坦请将其背对队员。
2.中了亡语瘟疫的话，请立刻跑到副坦克在拉的恐兽侧面，在DEBUFF第一跳（5秒）之前由开打前分配的专门人员将其驱散，然后归队，这样既可以使团队成员的DEBUFF被解掉，又能让瘟疫跳到恐兽身上，大大节省DPS。
综合以上，我们采取如上图所示的站位方式，远程DPS和治疗站外侧，主坦站内圈左侧拉BOSS和食尸鬼，副坦站外圈拉恐兽，中了瘟疫的近战或者远程第一时间跑到恐兽身后，等瘟疫解掉后返回。
此外，巫妖王每隔一段时间会施放寄生这个技能，寄生是一个对全团的伤害，戒律牧全团套盾可以很好的应付这个技能，所以戒律牧是必备职业。
按照如上所述将巫妖王的生命值攻击至70%以下则第一阶段结束，进入阶段转换。
第一、二阶段转换（持续1分钟）
转换阶段时，巫妖王会走向场地正中央，将霜之哀伤插入地面，这时，战斗场地转到外围的浮冰区（下一阶段会崩溃掉）。
看见巫妖王走向场地中间后，所有人要赶紧移动到外围浮冰区，第一阶段残留的蹒跚的血僵尸先坦在人群外，让死疽的伤害将蹒跚的血僵尸跳死（别忘了让副坦远离人群后解掉副坦身上的疾病）。

远程DPS和治疗可以分散站位到主坦的左右两侧的区域，只要不靠近副坦和恐兽就可以了。
巫妖王在阶段转换10秒时，会召唤一个狂怒的灵魂，并且之后每20秒都会召唤一个狂怒的灵魂。
灵魂是从被复制的玩家身边出现，因此坦克需要第一时间拉走，否则DPS容易被秒掉，而且该怪除了普通攻击之外，还会施放灵魂尖啸，造成锥形范围伤害，并附带5秒的沉默效果，坦克必须注意狂怒的灵魂的面向，DPS也不要跟坦克凑到一起。
第一、二转换阶段需要注意的地方：
1.坦克必须快速接住复制出的灵魂，同时还需要注意狂怒的灵魂的面向，不要面向玩家；
2.团队成员需要适当的分散，巫妖王会随机施放锥形范围伤害技能：痛苦受难；
3.远程的输出们快速打掉连线的寒冰球体，被撞倒了可是会10码范围内成员击出平台的哦！尤其是在从外围浮冰区往场地中央移动时，请特别注意。
DPS职业的工作以击杀狂怒的灵魂为主，转换阶段的时间为一分钟，所以总共会召唤三个狂怒的灵魂（前两个由主坦来拉，第三个由副坦来拉）。
在第三个狂怒的灵魂召唤出的10秒后，场地中央的巫妖王会将霜之哀伤拔起，外围浮冰区会开始崩解，团队成员必须在外围浮冰崩解前回到场地中央，否则会坠落下去无法再战斗。
第二阶段（70%-40%）
这个阶段由主坦克负责将巫妖王坦住，尽量坦克在场地中央的位置，近战DPS贴着巫妖王站，远程职业则是离巫妖王10码的距离，并且彼此分散站好，首先要先击杀转换阶段所留下来的狂怒的鬼魂。
首先要注意，巫妖王和第一阶段一样会施放寄生这个全体伤害技能，戒律牧必须准备给全团上盾；
第二阶段每隔一段时间，巫妖王会召唤一个华尔琪影卫（25人3只）。华尔琪影卫会随机抓住一名团队成员，并且往场地的外围飞去，飞出场地外围后会将此人丢出场地，而此人将坠落并且无法再参与战斗。
处理方法：当巫妖王开始召唤华尔琪影卫时，所有人像巫妖王靠拢，让华尔琪影卫抓的人是在团队中心的位置，距离场地外围较远，会有比较多的击杀时间。击杀时注意对华尔琪影卫全程保持减速效果，能晕则晕。

注意：术士由于灵魂法阵的存在是应对华尔琪的VIP职业，因为他们被抓了以后团队可以完全不用管，被扔下去利用法阵传上来即可。
巫妖王在该阶段还会随机选目标施放污染，站在黑水上的人会受到伤害，如果黑水上有人受到伤害则黑水的范围就会扩大，直至将整个场地都覆盖住。
第二阶段阶段跑污染需要注意的地方：
1.所有成员最好都将巫妖王设定成焦点目标，当巫妖王对自己施放污染时，跑离人群，黑水一出就跑开；
2.任何突发情况下，先离开黑水区域为重，就算暂时攻击不到华尔琪影卫也绝对不能让黑水扩散得太大。
除了对团队的伤害之外，巫妖王在第二阶段会对当前坦克施放灵魂收割这个技能，当巫妖王对当前坦克施放了灵魂收割之后，另一坦克必须马上将巫妖王嘲讽，最好能再开一个小的减伤技能或是增加血量的技能，安全系数会高许多。
第二、三阶段转换（持续1分钟）
重复第一、二阶段转换流程，处理好鬼魂和寒冰球体，胜利就在前方了。
第三阶段（40%-10%）
DPS先把转换阶段残留下来的狂怒的灵魂击杀掉后，就可以转而攻击巫妖王。巫妖王在这个阶段和第三阶段一样会使用寄生和污染以及灵魂收割这几个技能，不过不会再召唤华尔琪影卫，而是改为召唤每30秒召唤一波邪恶的灵魂以及新技能灵魂收割。
邪恶的灵魂刚被召唤出来的10秒钟会先在天空盘旋，10秒后会飞下来攻击仇恨者，一旦接触到目标则会产生灵魂爆裂，造成1万8左右的范围暗影伤害。
因此，卑劣的灵魂还在空中盘旋的时候，暗牧、术士、死亡骑士就要先对卑劣的灵魂AOE，削减他们的血量，其他的远程DPS单点击杀卑劣的灵魂，在飞下来之前能杀多少就杀多少。只要不要连续被两只邪恶的灵魂炸到，这伤害都不会致死。
卑劣的灵魂会受到任何减速效果的影响，并且可以被击飞，猎人在地上放好冰霜陷阱，搭配上平衡德的台风也有不错的效果。可以分配血多或者有自保技能的职业主动去帮忙撞掉一些卑劣的灵魂，减少伤害和治疗压力。
近战DPS主要的工作就是对巫妖王输出，因为远程DPS每30秒就要处理一次邪恶的灵魂，几乎没有什么余力能对巫妖王攻击，所以主要把巫妖王的血量打下去还是要靠近战DPS。

坦克可以先将巫妖王坦在场地边缘，召唤邪恶的灵魂后则将巫妖王带到场地的另一边，让灵魂飞行的距离远一点。
该阶段巫妖王会随机对一个非当前坦克的成员施放收割灵魂，玩家没死的话，就会被传送进入霜之哀伤的内部，在霜之哀伤的内部阿萨斯父亲的灵魂泰瑞纳斯．米奈希尔在跟灵魂看守者战斗，玩家必须在一分钟之内击败灵魂看守者，否则一分钟之后灵魂看守者会自爆，将在霜之哀伤内部的玩家还有泰瑞纳斯．米奈希尔都炸死。
而泰瑞纳斯．米奈希尔的灵魂一旦被灵魂看守者击杀，巫妖王就会有10秒钟的小狂暴，足以秒杀坦克，所以进入霜之哀伤内部的人员要尽量快速的击杀掉灵魂看守者，最好可以打断灵魂看守者的引导法术，这会让他回复生命力。如果是治疗职业进入霜之哀伤内部，可以治疗泰瑞纳斯．米奈希尔，让泰瑞纳斯．米奈希尔去攻击灵魂看守者，当然治疗者本身也要尽量对灵魂看守者攻击，因为只有一分钟的时间，治疗进去的话情况会特别紧张。
如果没有办法在一分钟之内击杀掉灵魂看守者，要马上通知外面的人员，猎人可以施放扰乱射击并且开威摄硬扛一段时间，圣骑士可以开无敌嘲讽，撑过这10秒钟的时间总比坦克被秒杀而导致灭团还好。
]]

--[[
玷污	对范围内所有敌人每秒造成暗影伤害。每次敌人从该效果受到伤害，伤害和范围就会增加，持续60秒，瞬发。
收割灵魂	尝试收割附近所有敌人的灵魂，每秒造成2000点暗影伤害直到取消。如果在该通道法术施放完成后目标仍活着，目标的灵魂会被霜之哀伤吞噬。80码，瞬发。
收割灵魂	尝试收割一个敌人的灵魂，每秒造成15000点暗影伤害，持续6秒。如果在该通道法术施放完成后目标仍活着，目标的灵魂会被霜之哀伤吞噬。60码，瞬发。
冷酷之冬	施放一个巨大的冬季风暴，对45码内所有敌人每秒造成14138 - 15862点冰霜伤害。瞬发。
痛苦与折磨	对前方锥形范围的目标造成7540 - 8460点暗影伤害。此外，目标每秒受到额外1200点暗影伤害，持续3秒。100码，5秒施法。
寄生	对50000码内所有敌人造成9425 - 10575点暗影伤害。此外，每1秒目标受到的暗影伤害提高。当目标的生命值大于90%时该效果会被移除。60码，20秒施法。
爆炸	对0码内所有目标造成25363 - 26437点暗影伤害。瞬发。
寒冰爆裂	对10码内所有目标造成28275 - 31725点冰霜伤害，并造成击退效果。瞬发。
灵魂收割者	造成60000点暗影伤害，并且巫妖王在5秒后获得100%的物理伤害加成。5码，瞬发。
骨疽瘟疫	在目标身上寄生致命瘟疫，每5秒造成100000点暗影伤害，持续15秒。如果目标在瘟疫持续期间死亡或效果结束，这个效果会叠加一次并传染到附近一个目标身上。如果这个效果被驱散，它将会失去一次叠加效果并且传染到附近一个目标身上。无论该效果何时传染，巫妖王的力量会提高。50000码，瞬发。
灵魂爆裂	牺牲施法者，对5码内所有敌人造成28275 - 31725点暗影伤害。瞬发。
绿色光线	传送邪恶之力给巫妖王。50000码，瞬发。
红色光线	传送邪恶之力给巫妖王。50000码，瞬发。
蓝色光线	传送冰霜之力给巫妖王。50000码，瞬发。
黑色光线	传送死亡之力给巫妖王。50000码，瞬发。
乌瑞恩的力量	暴风城的国王把他的力量借给你，提高30%的总生命值，治疗量和伤害。瞬发。
地狱咆哮的战歌	地狱咆哮的战歌赋予你力量，提高30%的总生命值，治疗量和伤害。瞬发。
成就
成就	描述
 冰封王座(25人)	25人模式下击败冰冠堡垒中的巫妖王
头衔：弑君者
 黎明之光	25人英雄模式下击败冰冠堡垒中的巫妖王
头衔：黎明之光
 为此已经等待很长时间了(25人)	25人模式下让骨疽瘟疫叠到30次后再击败巫妖王。
深陷邪恶(25人)	25人模式下在邪恶灵魂爆炸前杀死它们，然后击败巫妖王
 冰封王座(10人)	10人模式下击败冰冠堡垒中的巫妖王
头衔：弑君者
 堕落王子的毁灭	10人英雄模式下击败冰冠堡垒中的巫妖王
头衔：堕落王子的毁灭
 为此已经等待很长时间了(10人)	10人模式下让骨疽瘟疫叠到30次后再击败巫妖王。
深陷邪恶(10人)	10人模式下在邪恶灵魂爆炸前杀死它们，然后击败巫妖王
]]
