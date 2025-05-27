final Map<String, Map<String, dynamic>> accountList = {
  'manager9063': {
    'pwd': 'ur1w18a',
    'permission': 1,
    'name': '管理員'
  },
  'pinchou': {
    'pwd': '519253',
    'permission': 2,
    'name': '周穎彬'
  },
  'mickylin': {
    'pwd': '744582',
    'permission': 2,
    'name': '林怡均'
  },
  'seanlin': {
    'pwd': '490589',
    'permission': 2,
    'name': '林昇輝'
  },
};

// 儲存目前登入的帳號（nullable）
String? currentAccount;

// 快捷取得目前使用者資訊（若已登入）
Map<String, dynamic>? get currentUser =>
    currentAccount != null ? accountList[currentAccount] : null;