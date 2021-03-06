-----------------------------
--Utils
-----------------------------
function SocialQueueUtil_GetQueueName(queue)
	if ( queue.type == "lfg" ) then
		local lfgID = queue.lfgID;
		local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, _, _, isTimeWalker = GetLFGDungeonInfo(lfgID);
		if ( subtypeID == LFG_SUBTYPEID_DUNGEON ) then
			return string.format(SOCIAL_QUEUE_FORMAT_DUNGEON, name);
		elseif ( subtypeID == LFG_SUBTYPEID_HEROIC ) then
			return string.format(SOCIAL_QUEUE_FORMAT_HEROIC_DUNGEON, name);
		elseif ( subtypeID == LFG_SUBTYPEID_RAID ) then
			return string.format(SOCIAL_QUEUE_FORMAT_RAID, name);
		elseif ( subtypeID == LFG_SUBTYPEID_FLEXRAID ) then
			return string.format(SOCIAL_QUEUE_FORMAT_RAID, name);
		elseif ( subtypeID == LFG_SUBTYPEID_WORLDPVP ) then
			return string.format(SOCIAL_QUEUE_FORMAT_WORLDPVP, name);
		end
	elseif ( queue.type == "pvp" ) then
		local battlefieldType = queue.battlefieldType;
		local mapName = queue.mapName;
		if ( battlefieldType == "BATTLEGROUND" ) then
			return string.format(SOCIAL_QUEUE_FORMAT_BATTLEGROUND, mapName);
		elseif ( battlefieldType == "ARENA" ) then
			return string.format(SOCIAL_QUEUE_FORMAT_ARENA, queue.teamSize);
		elseif ( battlefieldType == "ARENASKIRMISH" ) then
			return SOCIAL_QUEUE_FORMAT_ARENA_SKIRMISH;
		else
			return mapName;
		end
	elseif ( queue.type == "lfglist" ) then
		if ( queue.lfgListID ) then
			return ( select(3, C_LFGList.GetSearchResultInfo(queue.lfgListID)) )
		end

		local activityID = queue.activityID;
		if ( activityID ) then
			local activityName, shortName, categoryID, groupID, minItemLevel, filters, minLevel, maxPlayers, displayType, _, useHonorLevel = C_LFGList.GetActivityInfo(activityID);
			return activityName;
		end
	end
	return UNKNOWNOBJECT;
end

function SocialQueueUtil_SetTooltip(tooltip, playerDisplayName, data)
	assert(data[1]);


	--For now, you can't queue for both LFGList and LFG+PvP.
	if ( data[1].type == "lfglist" ) then
		if ( C_LFGList.GetSearchResultInfo(data[1].lfgListID) ) then
			LFGListUtil_SetSearchEntryTooltip(tooltip, data[1].lfgListID);
		else
			--We're fading out.
			tooltip:SetText(playerDisplayName, 1, 1, 1, true);
		end
	else
		tooltip:SetText(playerDisplayName, 1, 1, 1, true);
		tooltip:AddLine(SOCIAL_QUEUE_QUEUED_FOR, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		for i=1, #data do
			local queue = data[i];
			local queueName = SocialQueueUtil_GetQueueName(queue);
			tooltip:AddLine(queueName, nil, nil, nil, true);
		end

		tooltip:AddLine(" ");
		tooltip:AddLine(SOCIAL_QUEUE_CLICK_TO_JOIN, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
	end
end

--returns name, color, relationship
function SocialQueueUtil_GetNameAndColor(guid)
	local hasFocus, characterName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText, broadcast, broadcastTime, online, bnetIDGameAccount, bnetIDAccount = BNGetGameAccountInfoByGUID(guid);
	if ( characterName and bnetIDAccount ) then
		local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client, isOnline, lastOnline, isBnetAFK, isBnetDND, messageText, noteText, isRIDFriend, messageTime, canSoR = BNGetFriendInfoByID(bnetIDAccount);
		if ( accountName ) then
			return accountName or UNKNOWNOBJECT, FRIENDS_BNET_NAME_COLOR_CODE, "bnfriend";
		end
	end

	if ( IsCharacterFriend(guid) ) then
		local name = select(6, GetPlayerInfoByGUID(guid));
		return name or UNKNOWNOBJECT, FRIENDS_WOW_NAME_COLOR_CODE, "wowfriend";
	end

	if ( IsGuildMember(guid) ) then
		local name = select(6, GetPlayerInfoByGUID(guid));
		return name or UNKNOWNOBJECT, RGBTableToColorCode(ChatTypeInfo.GUILD), "guild";
	end

	local name = select(6, GetPlayerInfoByGUID(guid));
	return name or UNKNOWNOBJECT, FRIENDS_WOW_NAME_COLOR_CODE;
end
