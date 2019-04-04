Address offs_CEconItemDefinition_pKeyValues,
		offs_CEconItemDefinition_u8MinLevel,
		offs_CEconItemDefinition_u8MaxLevel,
		offs_CEconItemDefinition_pszLocalizedItemName,
		offs_CEconItemDefinition_pszItemClassname,
		offs_CEconItemDefinition_pszItemName;
Address offs_CEconItemDefinition_aiItemSlot;

public int Native_GetItemName(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	bool bResult = LoadEconItemDefinitionString(defindex, offs_CEconItemDefinition_pszItemName,
			buffer, maxlen);
	
	if (bResult) {
		SetNativeString(2, buffer, maxlen, true);
	}
	return bResult;
}

public int Native_GetLocalizedItemName(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	bool bResult = LoadEconItemDefinitionString(defindex,
			offs_CEconItemDefinition_pszLocalizedItemName, buffer, maxlen);
	
	if (bResult) {
		SetNativeString(2, buffer, maxlen, true);
	}
	return bResult;
}

public int Native_GetItemClassName(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	int maxlen = GetNativeCell(3);
	
	char[] buffer = new char[maxlen];
	bool bResult = LoadEconItemDefinitionString(defindex,
			offs_CEconItemDefinition_pszItemClassname, buffer, maxlen);
	
	if (bResult) {
		SetNativeString(2, buffer, maxlen, true);
	}
	return bResult;
}

public int Native_GetItemSlot(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	TFClassType playerClass = GetNativeCell(2);
	return GetItemSlot(defindex, playerClass);
}

/**
 * Returns the slot an item can be used in by defindex, or -1 if invalid item or invalid class.
 */
int GetItemSlot(int defindex, TFClassType playerClass) {
	Address pItemDef = GetEconItemDefinition(defindex);
	if (!pItemDef) {
		return -1;
	}
	
	return LoadFromAddress(pItemDef + offs_CEconItemDefinition_aiItemSlot +
			view_as<Address>(view_as<int>(playerClass) * 4), NumberType_Int32);
}

public int Native_GetItemLevelRange(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	
	int iMinLevel, iMaxLevel;
	if (GetItemLevelRange(defindex, iMinLevel, iMaxLevel)) {
		SetNativeCellRef(2, iMinLevel);
		SetNativeCellRef(3, iMaxLevel);
		return true;
	}
	return false;
}

bool GetItemLevelRange(int defindex, int &iMinLevel, int &iMaxLevel) {
	Address pItemDef = GetEconItemDefinition(defindex);
	if (!pItemDef) {
		return false;
	}
	
	iMinLevel = LoadFromAddress(pItemDef + offs_CEconItemDefinition_u8MinLevel,
			NumberType_Int8);
	iMaxLevel = LoadFromAddress(pItemDef + offs_CEconItemDefinition_u8MaxLevel,
			NumberType_Int8);
	return true;
}

public int Native_GetItemDefinitionString(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	int keylen;
	GetNativeStringLength(2, keylen);
	keylen++;
	
	char[] key = new char[keylen];
	GetNativeString(2, key, keylen);
	
	int maxlen = GetNativeCell(4);
	char[] buffer = new char[maxlen];
	
	GetNativeString(5, buffer, maxlen);
	
	Address pItemDef = GetEconItemDefinition(defindex);
	if (pItemDef) {
		Address pKeyValues = DereferencePointer(pItemDef + offs_CEconItemDefinition_pKeyValues);
		if (KeyValuesPtrKeyExists(pKeyValues, key)) {
			KeyValuesPtrGetString(pKeyValues, key, buffer, maxlen, buffer);
		}
	}
	
	SetNativeString(3, buffer, maxlen, true);
}

public int Native_IsValidItemDefinition(Handle hPlugin, int nParams) {
	int defindex = GetNativeCell(1);
	return ValidItemDefIndex(defindex);
}

static bool LoadEconItemDefinitionString(int defindex, Address offset, char[] buffer,
		int maxlen) {
	Address pItemDef = GetEconItemDefinition(defindex);
	if (!pItemDef) {
		return false;
	}
	
	LoadStringFromAddress(DereferencePointer(pItemDef + offset), buffer, maxlen);
	return true;
}

// note: in CEconItemDefinition, defindex is at 0x08