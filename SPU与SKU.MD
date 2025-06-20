SPU是商品信息聚合的最小单位，是一个抽象的商品概念，代表一个具体的产品
interface SPU {
  id: number;                    // SPU ID
  name: string;                  // 商品名称
  description: string;           // 商品描述
  categoryId: number;            // 分类ID
  brandId: number;               // 品牌ID
  mainImage: string;             // 主图
  images: string[];              // 商品图片列表
  detailImages: string[];        // 详情图片
  status: number;                // 状态：0-下架，1-上架
  sort: number;                  // 排序
  isRecommend: boolean;          // 是否推荐
  isHot: boolean;                // 是否热销
  isNew: boolean;                // 是否新品
  createTime: string;            // 创建时间
  updateTime: string;            // 更新时间
}
SPU示例
iPhone 15 - 这是一个SPU
华为Mate 60 - 这是一个SPU
小米14 - 这是一个SPU

SKU (Stock Keeping Unit) - 库存量单位
定义
SKU是具体的商品规格，是SPU的具体化，代表可以实际购买的商品。
interface SKU {
  id: number;                    // SKU ID
  spuId: number;                 // 所属SPU ID
  skuCode: string;               // SKU编码
  name: string;                  // SKU名称
  price: number;                 // 价格
  originalPrice: number;         // 原价
  costPrice: number;             // 成本价
  stock: number;                 // 库存数量
  stockWarn: number;             // 库存预警数量
  weight: number;                // 重量(kg)
  volume: number;                // 体积(m³)
  barcode: string;               // 条形码
  specifications: SKUSpec[];     // 规格属性
  images: string[];              // SKU图片
  status: number;                // 状态：0-下架，1-上架
  isDefault: boolean;            // 是否默认SKU
  createTime: string;            // 创建时间
  updateTime: string;            // 更新时间
}

interface SKUSpec {
  specId: number;                // 规格ID
  specName: string;              // 规格名称
  specValueId: number;           // 规格值ID
  specValue: string;             // 规格值
}

SKU示例
以iPhone 15为例：
iPhone 15 128GB 黑色 - 这是一个SKU
iPhone 15 256GB 白色 - 这是一个SKU
iPhone 15 512GB 蓝色 - 这是一个SKU

常见规格示例
颜色：黑色、白色、蓝色、红色
尺寸：S、M、L、XL、XXL
容量：128GB、256GB、512GB、1TB
材质：棉质、丝绸、皮革

SPU (iPhone 15)
├── SKU (128GB 黑色) - 价格：5999元，库存：100
├── SKU (256GB 白色) - 价格：6999元，库存：50
└── SKU (512GB 蓝色) - 价格：8999元，库存：30