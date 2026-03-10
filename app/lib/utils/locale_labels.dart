/// Translation maps for the fixed set of English category/functionality
/// labels stored in the DB, used when the app is in Chinese mode.
library locale_labels;

const Map<String, String> kCategoryZh = {
  'Serum': '精華',
  'Face Mask': '面膜',
  'Moisturizer': '保濕霜',
  'Cleanser': '潔面',
  'Sunscreen': '防曬',
  'Eye Care': '眼部護理',
  'Makeup Remover': '卸妝',
  'Lip Care': '唇部護理',
  'Toner': '爽膚水',
  'Lotion': '乳液',
  'Eye Mask': '眼膜',
  'Toner Pads': '棉片',
  'Exfoliator': '去角質',
  'Mist': '噴霧',
  'Face Oil': '護膚油',
  'Supplement': '保健品',
  'Body Care': '身體護理',
  'Scalp Care': '頭皮護理',
  'Skincare': '護膚',
};

const Map<String, String> kFunctionalityZh = {
  'Hydrating': '保濕',
  'Anti-aging': '抗老',
  'Repairing': '修護',
  'Firming': '緊緻',
  'Brightening': '提亮',
  'SPF Protection': '防曬',
  'Soothing': '舒緩',
  'Pore Cleansing': '毛孔清潔',
  'Exfoliating': '去角質',
  'Oil Control': '控油',
};

String localCategory(String en, String locale) =>
    locale.startsWith('zh') ? (kCategoryZh[en] ?? en) : en;

String localFunctionality(String en, String locale) =>
    locale.startsWith('zh') ? (kFunctionalityZh[en] ?? en) : en;
