final Map<String, Map<String, dynamic>> accountList = {
  'manager9063': {'pwd': 'ur1w18a', 'permission': 1, 'name': '管理員'},
  'pinchou': {'pwd': '519253', 'permission': 2, 'name': '周穎彬'},
  'mickylin': {'pwd': '744582', 'permission': 2, 'name': '林怡均'},
  'seanlin': {'pwd': '490589', 'permission': 2, 'name': '林昇輝'},
  // Vietnamese colleagues
  'haiyan': {
    'pwd': 'V2212010',
    'permission': 1,
    'name': '阮氏海燕',
    'vn_name': 'Nguyễn Thị Hải Yến',
    'employee_id': 'V2212010'
  },
  'camtu': {
    'pwd': 'V2505003',
    'permission': 2,
    'name': '陳氏錦宿',
    'vn_name': 'Trần Thị Cẩm Tú',
    'employee_id': 'V2505003'
  },
  'thihiep': {
    'pwd': 'V1911069',
    'permission': 2,
    'name': '黎氏郟',
    'vn_name': 'Lê Thị Hiệp',
    'employee_id': 'V1911069'
  },
  'kimanh': {
    'pwd': 'V2403003',
    'permission': 2,
    'name': '阮氏金英',
    'vn_name': 'Nguyễn Thị Kim Anh',
    'employee_id': 'V2403003'
  },
  'thiloan': {
    'pwd': 'V2508066',
    'permission': 2,
    'name': '鄭氏鸞',
    'vn_name': 'Trịnh Thị Loan',
    'employee_id': 'V2508066'
  },
};

// 儲存目前登入的帳號（nullable）
String? currentAccount;

// 快捷取得目前使用者資訊（若已登入）
Map<String, dynamic>? get currentUser =>
    currentAccount != null ? accountList[currentAccount] : null;
