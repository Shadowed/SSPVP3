----汉化by 血煞天魂@2区轻风之语
if( GetLocale() ~= "zhCN" ) then
	return
end

SSPVPLocals = setmetatable({
	-- Battlefield names
	["Warsong Gulch"] = "战歌峡谷",
	["Arathi Basin"] = "阿拉希盆地",
	["Alterac Valley"] = "奥特兰克山谷",
	["Eye of the Storm"] = "风暴之眼",

	["Blade's Edge Arena"] = "刀锋山竞技场",
	["Nagrand Arena"] = "纳格兰竞技场",
	["Ruins of Lordaeron"] = "洛丹伦废墟",
	
	["Rated"] = "积分赛",
	["Skirmish"] = "练习赛",
	["Arena"] = "竞技场",
	["All Arenas"] = "全部竞技场",
	["%s (%dvs%d)"] = "%s (%dvs%d)",
	["Rated Arena"] = "积分赛竞技场",
	["Skirmish Arena"] = "练习赛竞技场",

	["You are now in the queue for %s Arena (%dvs%d)."] = "你在进入%s竞技场(%dVS%d)的队列。",
	["You are now in the queue for %s."] = "你在进入%s的队列。",
	
	["Higher priority battlefield ready, auto joining %s in %d seconds."] = "高优先级的战场可用,即将在%d秒内自动进入%s。",
	["You're current activity is a higher priority then %s, not auto joining."] = "你目前已在战场中或处于战斗状态，战场助手取消自动进入%s。",
	["You have the battlefield entry window hidden for %s, will not auto join."] = "你已经隐藏战场进入窗口，战场助手取消自动进入%s。",
	
	["%s %d points (%d rating)"] = "%s %d 点数 (%d 级别)",
	["/ %d personal (%d rating)"] = "/ %d 点数 (%d 级别)",
	
	["You are about to leave the active or queued arena %s (%dvs%d), are you sure?"] = "你确定要离开%s (%dvs%d)正在打或者排队的竞技场吗？",
	["You are about to leave the active or queued battleground %s, are you sure?"] = "你确定要离开%s正在打或者排队的战场吗？",
	
	["Horde"] = "部落",
	["Alliance"] = "联盟",
	["Screenshot saved as WoWScrnShot_%s.%s."] = "截图已保存为WoWScrnShot_%s.%s.",
	
	["(L) %s"] = "(L) %s",
	["Rating"] = "级别",
	
	["Releasing..."] = "释放...",
	["Using %s..."] = "使用%s...",
	
	["Starting: %s"] = "战斗%s后开始",
	
	["the raid group.$"] = "团队队伍。$",
	
	["The"] = "",
	
	["Alliance"] = "联盟",
	["Horde"] = "部落",
	
	["[%s] %s: %s"] = "[%s] %s: %s",
	
	["Unavailable"] = "不可用",
	["<1 Min"] = "小于1分钟",
	["Join Suspended"] = "进入悬挂的队列",
	["Join Disabled"] = "进入取消的队列",
	["Joining"] = "进入",
	["(.+) Mark of Honor"] = "(.+)荣誉徽章",
	["%s |cffffffff(%dvs%d)|r"] = "%s |cffffffff(%dvs%d)|r",
	["Flag Respawn: %s"] = "旗帜重置时间: %s",
	["Auto release disabled, %d %s until release"] = "自动释放禁用，%d %s直到释放。",
	
	["%d personal rating in %s (%dvs%d)"] = " %s (%dvs%d)的个人得分为%d。",
	["%s is ready to join, auto leave disabled."] = "%s准备进入，自动离开关闭。",
	
	-- Modified queue window
	["You can now enter %s and have %s left."] = "你现在可以确认%s，并可离开%s。",
	
	
	-- Mover
	["PvP Objectives Anchor"] = "PvP目标框体锚点",
	["Score Objectives Anchor"] = "记分板框体锚点",
	["Left Click + Drag to move the frame, Right Click + Drag to reset it to it's original position."] = "左键点击拖动用于移动框体，右键点击拖动用于重新设置原始位置。",
	
	-- Win API is broken /wrist
	["The Horde wins"] = "部落获胜",
	["The Alliance wins"] = "联盟获胜",
	
	-- So we don't auto leave before completing
	["Call to Arms: %s"] = "加入战斗: %s",
	["You currently have the battleground daily quest for %s, auto leave has been set to occure once the quest completes."] = "%s有你的每日战场任务，如果任务完成则自动离开。",
	
	-- Modified arena info
	["Season"] = "本赛季",
	["Week"] = "本周",
	
	-- Flags
	["Alliance flag carrier %s, held for %s."] = "联盟旗帜被%s夺取,%s拿旗。",
	["Horde flag carrier %s, held for %s."] = "部落旗帜被%s夺取,%s拿旗。",
	
	["was picked up by (.+)!"] = "被(.+)拔起了！",
	["captured the"] = "夺取了",
	["was dropped by (.+)!"] = "被(.+)丢掉了！",
	["was returned to its base"] = "还到了它的基地中！",
	
	["(.+) has taken the flag!"] = "(.+)已经夺走了旗帜!",
	["The flag has been dropped"] = "旗帜被([^%s]+)丢掉了",
	
	["Held Time: %s"] = "持旗时间: %s",
	["Capture Time: %s"] = "夺取时间: %s",
	
	["Targetting %s"] = "以%s为目标",
	["%s is out of range"] = "%s不在范围",
	
	-- Sync queuing for AV
	["You must be in a raid or party to do this."] = "你必须是队长才能这样做。",
	["You must be group leader, or assist to do this."] = "你必须是队长或者团长才能这样做",
	["You have been queued for Alterac Valley by %s."] = "%s帮你加入了奥特兰克山谷的团排。",
	["You provided an invalid instance ID to join."] = "你加入了一个无效的战场队列。",
	
	["Queuing %d seconds."] = "奥特兰克山谷已经排队%d秒。",
	["Queuing %d second."] = "奥特兰克山谷已经排队%d秒。",
	["Queue for Alterac Valley!"] = "奥特兰克山谷队列!",
	
	["Battlemaster window ready check started, you have 10 seconds to get the window open."] = "战场准备检查启用，你有10秒钟开启窗口。",
	["Leaving Alterac Valley queues."] = "取消团排奥山。",
		
	["Alterac Valley sync queue has been stopped by %s."] = "%s停止了奥特兰克山谷的团排。",
	["Alterac Valley queue stopped."] = "团排奥山已停止。",
	["Alterac Valley queue has been dropped by %s."] = "%s取消了奥特兰克山谷的团排。",
	
	["Forcing join on instance #%d."] = "强制加入战场#%d。",
	["Invalid number entered for sync queue."] = "无效的人群申请参加团排。",
	["Joining Alterac Valley #%d at the request of %s"] = "%s请求加入奥山#%d。",
	["%s has requested you join Alterac Valley #%d, but you have force join disabled."] = "%s已经请求加入奥山#%d，但是你可以强制取消。",
	
    ["Ready: %s"] = "准备好: %s",
	["Not Ready: %s"] = "未准备好: %s",
	["Everyone is ready to go!"] = "所有人都准备好了",
	
	-- Queue status GUI for AV
	["Queue Status"] = "排队状态",
	["Name"] = "名字",
	["Status"] = "状态",
	["Queue"] = "队列",
	["Version"] = "版本",
	
	["Unknown"] = "未知",
	["Not queued"] = "没有队列",
	["Inside #%d"] = "#%d内部",
	["Confirm #%d"] = "证实 #%d",
	["Queued Any"] = "任意队列",
	["Queued #%d"] = "队列 #%d",
	["Offline"] = "离线",
	["Online"] = "在线",
	["Ready"] = "准备好",
	["Not ready"] = "未准备好",
	
	["Total Players"] = "总体玩家",
	["Ready"] = "准备好",
	["Not Ready"] = "未准备好",
	
	["Ready Check"] = "准备检查",
	["Sync Queue"] = "同步队列",
	["Drop Queue"] = "取消队列",
	
	["New version available!"] = "新版本可用！",
	["AFK"] = "AFK",
	["Next Update"] = "下一次更新",
	["You are about to send a queue drop request, are you sure?"] = "你将要发送队列取消请求，你确定么？",
	
	-- CT support
	["-%d Reinforcements"] = "-%d 援兵",
	["+%d Points"] = "+%d 荣誉点数",
	
	-- Score tooltip
	["%s (%d players)"] = "%s (%d玩家)",
	["Servers"] = "服务器",
	["Classes"] = "职业",
	
	-- Arathi basin
	["claims the ([^!]+)"] = "占领了([^!]+)",
	["has taken the ([^!]+)"] = "夺取了([^!]+)",
	["has assaulted the ([^!]+)"] = "突袭了([^!]+)",
	["has defended the ([^!]+)"] = "守住了([^!]+)",
	
	["Bases: ([0-9]+)  Resources: ([0-9]+)/2000"] = "基地：([0-9]+)  资源：([0-9]+)/2000",
	["Final Score: %d"] = "最终得分: %d",
	["Time Left: %s"] = "时间剩余: %s",
	["Bases to win: %d"] = "占领的基地: %d",
	["Base Final: %d"] = "最终基地: %d",
	
	-- Alterac valley
	["Herald"] = "通报者",
	["Snowfall Graveyard"] = "雪落墓地",
	["claims the Snowfall graveyard"] = "攻占了雪落墓地！",
	["(.+) is under attack"] = "(.+)受到攻击！",
	["(.+) was taken"] = "([^%s]+)被([^%s]+)占领了！",
	["(.+) was destroyed"] = "([^%s]+)被([^%s]+)摧毁了！",
	
	["Reinforcements: ([0-9]+)"] = "援兵: ([0-9]+)",
	["%s will be captured by the %s in %s"] = "在%s后，%s将会被%s夺取！",
	
	-- Eye of the Storm
	["Bases: ([0-9]+)  Victory Points: ([0-9]+)/2000"] = "基地：([0-9]+)  资源：([0-9]+)/2000",
	["Bases %d  Points %d/2000"] = "基地 %d 胜利点数 %d/2000",
	["flag has been reset"] = "旗帜被重新放置了。",
	
	-- Gods
	["Ivus the Forest Lord"] = "森林之王伊弗斯",
	["Lokholar the Ice Lord"] = "冰雪之王洛克霍拉",
	
	["Ivus Moving: %s"] = "森林之王正在移动: %s",
	["Lokholar Moving: %s"] = "冰雪之王正在移动: %s",
	
	["Wicked, wicked, mortals"] = "邪恶, 太邪恶了, 人类",
	["WHO DARES SUMMON LOKHOLA"] = "谁敢召唤洛克霍拉",

	-- Captain Galvangar
	["Captain Galvangar"] = "加尔范上尉",
	
	["The Alliance has slain Captain Galvangar."] = "联盟已经杀死加尔范上尉了。",
	["The Alliance has engaged Captain Galvangar."] = "联盟开始杀加尔范上尉了。",
	["The Alliance has reset Captain Galvangar."] = "有人出要塞，加尔范上尉恢复了。",
	
	["Your kind has no place in Alterac Valley"] = "去死吧！你们别想在奥特兰克山谷站住脚！",
	["I'll never fall for that, fool!"] = "我永远不会被你那点伎俩算计到，蠢货！如果你想要一战的话，那就到我的地盘来挑战我吧！",
	
	-- Captain Balinda
	["Captain Balinda Stonehearth"] = "巴琳达·斯通赫尔斯",
	
	["The Horde has slain Captain Balinda Stonehearth."] = "部落已经杀死巴琳达·斯通赫尔斯了。",
	["The Horde has engaged Captain Balinda Stonehearth."] = "部落开始杀巴琳达·斯通赫尔斯了。",
	["The Horde has reset Captain Balinda Stonehearth."] = "有人出要塞，巴琳达·斯通赫尔斯恢复了。",
	
	["Begone, uncouth scum!"] = "去死吧，渣滓！联盟会获得胜利的!",
	["Filthy Frostwolf cowards"] = "可恶的霜狼懦夫！如果你们想要一战的话，就放马，不，放狼过来吧！",
	
	-- Drek'Thar
	["Drek'Thar"] = "德雷克塔尔",
	
	["The Alliance has engaged Drek'Thar."] = "联盟开始杀德雷克塔尔了。",
	["The Alliance has reset Drek'Thar."] = "有人出要塞，德雷克塔尔恢复了。",
	
	["Stormpike weaklings"] = "虚弱的雷矛",
	["Stormpike filth!"] = "雷矛的渣子!",
	["You seek to draw the General of the Frostwolf"] = "你想把霜狼的将军拉出他的要塞",
	
	-- Vanndar
	["Vanndar Stormpike"] = "范达尔·雷矛",
	
	["The Horde has reset Vanndar Stormpike."] = "有人出要塞，范达尔·雷矛恢复了。",
	["The Horde has engaged Vanndar Stormpike."] = "部落开始杀范达尔·雷矛了。",
	
	["Why don't ya try again"] = "为什么不再试一次",
	["Soldiers of Stormpike, your General is under attack"] = "雷矛的士兵,你们的将军被攻击",	
	["You'll never get me out of me"] = "你永远不能打败我",	

	-- Text for catching time until match starts
	["2 minute"] = "2分钟",
	["1 minute"] = "1分钟",
	["30 seconds"] = "30秒",
	["Fifteen seconds"] = "15秒",
	["Thirty seconds"] = "30秒",
	["One minute"] = "1分钟",
	
	-- Slash commands
	["SSPVP Arena slash commands"] = "SSPVP竞技场设置命令",
	[" - rating <rating> - Calculates points given from the passed rating."] = " - rating <rating> - 计算提高到某一级别所需要的点数。",
	[" - points <points> - Calculates rating required to reach the passed points."] = " - points <points> - 计算提高到某一级别你能获得多少荣誉点数。",
	[" - attend <played> <team> - Calculates games required to reach 30% using the passed games <played> out of the <team> games played."] = " - attend <played> <team> - 计算你需要在队伍中参加多少场比赛才能得到竞技场成绩。",
	[" - change <winner rating> <loser rating> - Calculates points gained/lost assuming the <winner rating> beats <loser rating>."] = " - change <winner rating> <loser rating> - 计算你胜利或者失去的点数。",
	
	["SSPVP Alterac Valley slash commands"] = "SSPVP奥山设置命令",
	[" - sync <seconds> - Starts a count down for an Alterac Valley sync queue."] = " - sync <秒> - 奥山团排计时时间。",
	[" - cancel - Cancels a running sync."] = " - cancel - 取消已经开始的团排计时。",
	[" - drop - Drops all Alterac Valley queues."] = " - drop - 取消所有的团排奥山。",
	[" - update - Forces a status update on everyones Alterac Valley queues."] = " - update - 强制更新团排奥山的状态。",
    [" - ready - Does a check to see who has the battlemaster window open and is ready to queue."] = " - ready - 检查队友的战场窗口是否开启病是否准备好。",
	[" - join <instanceID> - Forces everyone with the specified instance id to join Alterac Valley."] = " - join <instanceID> - 强制每一个人加入一个特定的奥山队列。",
	[" - status - Shows the status list of everyone regarding queue or window."] = " - status - 显示关于团队中团排的个人信息。",
	
	["You do not have Alterac Valley syncing enabled, and cannot use any of the slash commands yourself."] = "你没有开启团排奥山选项, 你不能使用任何相关配置命令",
	
	["SSPVP slash commands"] = "SSPVP设置命令",
	[" - suspend - Suspends auto join and leave for 5 minutes, or until you log off."] = " - suspend - 挂起自动加入并离开5分钟，或者直到你手动取消。",
	[" - ui - Opens the OptionHouse configuration for SSPVP."] = " - ui - 打开SSPVP2配置界面",
	[" - Other slash commands"] = " - 其他设置命令",
	[" - /av - Alterac Valley sync queuing."] = " - /av - 团排奥山。",
	[" - /arena - Easy Arena calculations and conversions"] = " - /arena - 简单的竞技场计算和换算",
	
	
	["Auto join and leave has been suspended for the next 5 minutes, or until you log off."] = "5分钟内自动加入和离开被悬挂，或者你可以手动取消。",
	["Suspension has been removed, you will now auto join and leave again."] = "悬挂已被取消，你可以再次自动加入和离开",
	["Suspension is still active, will not auto join or leave."] = "悬挂仍被开启，不能自动加入和离开",
	
	["[%d vs %d] %d rating = %d points"] = "[%d vs %d] %d 级别 = %d 荣誉点数",
	["[%d vs %d] %d rating = %d points - %d%% = %d points"] = "[%d vs %d] %d 级别 = %d 荣誉点数 - %d%% = %d 荣誉点数",
	["[%d vs %d] %d points = %d rating"] = "[%d vs %d] %d 荣誉点数 = %d 级别",
	
	["%d games out of %d total is already above 30%% (%.2f%%)."] = "%d的战斗已经超出%d total所需的30%% (%.2f%%).",
	["%d more games have to be played (%d total) to reach 30%%."] = "%d需要更多场(%d total)战斗才能达到30%%。",
	
	["+%d points (%d rating) / %d points (%d rating)"] = "+%d 荣誉点数 (%d 级别) / %d 荣誉点数 (%d 级别)",

	-- Overlay categories
	["Faction Balance"] = "阵营人数情况",
	["Timers"] = "计时器",
	["Match Info"] = "战场信息",
	["Bases to win"] = "距离获胜",
	["Mine Reinforcement"] = "我方援兵",
	["Battlefield Queue"] = "战场队列",
	["Frame Moving"] = "框体移动",
	["Alterac Valley sync queuing"] = "团排奥山",
	
	-- GOOEY
	["General"] = "一般设置",
	["Auto Queue"] = "自动排队",
	["Battlefield"] = "战场",
	["Overlay"] = "提示信息",
	["Auto Join"] = "自动进入",
	["Display"] = "显示",

	-- GENERAL
	["Play"] = "播放",
	["Stop"] = "停止",
	
	["Sound file"] = "声音文件",
	["Timer channel"] = "计时器频道",
	["Show team summary after rated arena ends"] = "积分赛结束后显示团队概要",
	["Auto append server name while in battlefields for whispers"] = "自动在战场密语的时候附加服务器名",
	["Auto queue when inside of a group and leader"] = "当为队伍领导时自动排队",
	["Battleground"] = "战场",
	["Party"] = "小队",
	["Raid"] = "团队",
	
	["Shows how much personal rating you gain/lost, will only show up if it's no the same amount of points as your actual team got."] = "显示你得到/失去的个人等级，如有不同，则按实际队伍显示。",

	["Show personal rating change after arena ends"] = "竞技场结束以后显示个人等级",
	
	["Automatically append \"-server\" to peoples names when you whisper them, if multiple people are found to match the same name then it won't add the server."] = "当你密语别人时自动添加服务器名称, 如果发现在同一服务器，那么它将不添加服务器名称。",
	["Shows team names, points change and the new ratings after the arena ends."] = "竞技场结束后显示队伍名称，点数改变和新的等级。",
	["Channel to output to when you send timers out from the overlay."] = "从框体显示你发布计时器时候的输出频道。",
	["Sound file to play when a queue is ready, file must be inside Interface/AddOns/SSPVP before you started the game."] = "当队列准备时声音文件被播放，文件必须在游戏启动前放入Interface/AddOns/SSPVP2内。",
	
	["Auto queue when outside of a group"] = "没有队伍时自动单排",
	["Auto queue when inside a group and leader"] = "当为队伍领导时自动排队",
	
	["Queue Overlay"] = "排队界面",
	["Enable battlefield queue status"] = "开启战场排队状态",
	["Show inside an active battlefield"] = "在战场中显示",
	
	
	["Lock PvP objectives"] = "锁定PVP目标",
	["Lock scoreboard"] = "锁定记分牌",
	["Lock capture bar"] = "锁定计时条",
	["Shows an anchor above the frame that lets you move it, the frame you're trying to move may have to be visible to actually move it."] = "显示用于移动框体的标题，你可以尝试去移动到你所需要的地方。",
	
	-- BATTLEFIELD
	["Death"] = "死亡",
	["Scoreboard"] = "记分牌",
	["Color player name by class"] = "名字用职业颜色显示",
	["Hide class icon next to names"] = "在名字后隐藏职业图标",
	["Show player levels next to name"] = "名字后边显示玩家等级",
	["Release from corpse when inside an active battleground"] = "战场中自动释放",
	["Release even with a soul stone active"] = "忽略灵魂石释放灵魂",
	
	-- AUTO JOIN
	["Delay"] = "延迟",
	["Join priorities"] = "进入优先级战场",
	["Enable auto join"] = "开启自动进入",
	["Priority check mode"] = "优先级覆盖模式",
	["Less than"] = "小于",
	["Less than/equal"] = "小于或者等于",
	["Battleground join delay"] = "战场进入延时",
	["AFK battleground join delay"] = "离开战场延时",
	["Arena join delay"] = "竞技场进入延时",
	["Don't auto join a battlefield if the queue window is hidden"] = "当队列窗口被隐藏时不自动进入战场",
	
	-- AUTO LEAVE
	["Auto Leave"] = "自动离开",
	["Confirmation"] = "确认",
	["Confirm when leaving a battlefield queue through minimap list"] = "当离开一个战场队列时需要确认",
	["Confirm when leaving a finished battlefield through score"] = "当离开已经结束的战场时需要确认",
		
	["Battlefield leave delay"] = "离开战场延迟",
	["Enable auto leave"] = "开启自动离开",
	["Screenshot score board when game ends"] = "结束时对得分截图",
	
	
	-- OVERLAY
	["Frame"] = "框体",
	["Color"] = "颜色",
	["Lock overlay"] = "锁定屏幕显示",
	["Background opacity: %d%%"] = "背景透明度: %d%%",
	["Scale: %d%%"] = "文字透明度: %d%%",
	["Background color"] = "背景颜色",
	["Border color"] = "边框颜色",
	["Category text color"] = "标题颜色",
	["Text color"] = "文字颜色",
	["Grow up"] = "增长",
	["The overlay will grow up instead of down when new rows are added, a reloadui maybe required for this to take affect."] = "当一个新的队列别添加时框体会向下增长, 也许需要重新加载插件。",

	["Disable overlay clicking"] = "禁用提示信息",
	["Removes the ability to click on the overlay, allowing you to interact with the 3D world instead. While the overlay is unlocked, this option is ignored."] = "移除提示信息。框体被解锁，不过这个选项默认被关闭",
	
	-- AV
	["Alerts"] = "报警",
	["Timers"] = "计时器",
	["Enable capture timers"] = "开启占领计时器",
	["Enable interval capture messages"] = "开启间隔获取信息",
	["Seconds between capture messages"] = "获取信息间隔时间（秒）",
	["Show resources gained through mines"] = "显示获得的资源",
	["Show resources lost from captains in towers in MSBT/SCT/FCT"] = "在MSBT/SCT/FCT显示失去的岗哨指挥官。",
	["None"] = "无",
	["25%"] = "25%",
	["50%"] = "50%",
	["75%"] = "75%",
	
	["Sync Queue"] = "团队排队",
	["Enable sync queuing"] = "开启团队排队",
	["Allows you to sync queue with other SSPVP2, StinkyQueue or LightQueue users at the same time increasing your chance of getting into the same match."] = "允许你连同其他的SSPVP2, StinkyQueue 或 LightQueue 的使用者增加你进入相同战场的机会（团排）。",
	["Allow group leader or assist to force join you into a specific Alterac Valley"] = "允许团长或助理强制帮你排入指定奥山战场",
	
	["Show player queue status in overlay"] = "显示玩家队列状态",
	["Displays how many people are queued, number of people who have confirmation for specific instance id's and the instance id's that people are currently playing inside."] = "显示多少人正在排队，并显示队员的一些信息。",
	["When the leader is ready for the group to join an Alterac Valley, he can force everyone into it with the required instance id. You will still be shown the instance id to join even if you disable this."] = "当团长准备加入一个团排奥山时，他可以强制每个人加入一个相同的战场队列。你可以一直显示队列即使你取消了它。",
	
	-- EOTS/AB/WSG
	["Flag Carrier"] = "夺取旗帜",
	["Match Info"] = "战场信息",
	
	["Show flag carrier"] = "显示旗帜持有者",
	["Show carrier health when available"] = "当目标有效时显示持有者状态",
	["Color carrier name by class color"] = "用职业色彩显示持有者名字",
	["Time until flag respawns"] = "旗子重置时间",
	
	["Show basic match information"] = "显示基本比赛信息",
	["Show bases to win"] = "显示占领的基地",
	["Show flag held time and time taken to capture"] = "显示旗子持有时间和占领时间",
	
	["Show points gained from flag captures in MSBT/SCT/FCT"] = "在MSBT/SCT/FCT显示占领旗子所得到的点数。",
	
	["Macro Text"] = "宏文本",
	["Text to execute when clicking on the flag carrier button"] = "写入当你点击旗帜持有者按钮时执行的动作",
	
	-- Disable modules
	["Modules"] = "模块",
	["Disable %s"] = "禁用%s",
	["match information"] = "比赛信息",
	["Time left in match, final scores and bases to win for Eye of the Storm and Arathi Basin."] = "风暴之眼和阿拉希盆地显示计时信息，最终得分和占领的基地",
	
	["flag carrier"] = "旗帜持有者",
	["Who's holding the flag currently for Eye of the Storm and Warsong Gulch."] = "在风暴之眼和战歌峡谷显示谁持有旗子。",

	["Timers for Arathi Basin when capturing nodes."] = "阿拉希盆地夺取基地计时器",

	["Timers for Alterac Valley when capturing nodes, as well interval alerts on time left before capture."] = "阿拉希盆地夺取基地计时器, 以防止确实占领前受到攻击",
	["Cleaning up the text in the PvP objectives along with points gained from captures in Eye of the Storm."] = "风暴之眼中随着占领点数的更新而随时清除PVP目标",
	
	["battleground"] = "战场",
	["General battleground specific changes like auto release."] = "战场中更改自动释放。",
	
	["score"] = "得分",
	["General scoreboard changes like coloring by class or hiding the class icons."] = "记分板下更改职业颜色或者隐藏职业图标",
	
	["Disable auto release"] = "禁用自动释放",
	["Disables auto release for this specific battleground."] = "在战场时关闭自动释放。",
	
	-- Priorities
	["afk"] = "暂离",
	["ratedArena"] = "积分赛",
	["skirmArena"] = "练习赛",
	["eots"] = "风暴之眼",
	["av"] = "奥特兰克山谷",
	["ab"] = "阿拉希盆地",
	["wsg"] = "战歌峡谷",
	["group"] = "已组队",
	["instance"] = "战斗状态",
	["none"] = "其它情况",
	
    }, {__index = SSPVPLocals});
	
	BINDING_HEADER_SSPVP = "SSPVP";
    BINDING_NAME_ETARFLAG = "选中敌方持旗者";
    BINDING_NAME_FTARFLAG = "选中我方持旗者";

SSPVPRevision = tonumber(string.match("$Revision: 461 $", "(%d+)")) or 0