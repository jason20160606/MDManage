/*
 Navicat Premium Dump SQL

 Source Server         : MDManage
 Source Server Type    : MySQL
 Source Server Version : 80042 (8.0.42)
 Source Host           : localhost:3306
 Source Schema         : mdmanage

 Target Server Type    : MySQL
 Target Server Version : 80042 (8.0.42)
 File Encoding         : 65001

 Date: 19/06/2025 00:56:07
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for brands
-- ----------------------------
DROP TABLE IF EXISTS `brands`;
CREATE TABLE `brands`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '品牌名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '品牌描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1013 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of brands
-- ----------------------------
INSERT INTO `brands` VALUES (1001, '蜜都', '9sVkddlbbC');
INSERT INTO `brands` VALUES (1002, '美的', '6lyr6H2p6x');
INSERT INTO `brands` VALUES (1003, '苹果', '6MN1Ho9uzR');
INSERT INTO `brands` VALUES (1004, '方太', '6BkUGTizo2');
INSERT INTO `brands` VALUES (1005, '华为', 'pAHUzGZjzf');
INSERT INTO `brands` VALUES (1006, '统一', 'v9NzcNOnhl');
INSERT INTO `brands` VALUES (1007, '小米', '058fFa8v8a');
INSERT INTO `brands` VALUES (1008, '奇瑞', 'vYPO2Lgmlb');
INSERT INTO `brands` VALUES (1009, '比亚迪', 'kfOVaJzGNZ');
INSERT INTO `brands` VALUES (1010, '康师傅', 'HlzQ89fAuz');
INSERT INTO `brands` VALUES (1011, '蜜雪冰城', '蜜雪冰城');

-- ----------------------------
-- Table structure for customer_addresses
-- ----------------------------
DROP TABLE IF EXISTS `customer_addresses`;
CREATE TABLE `customer_addresses`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `receiver_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人电话',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货地址',
  `is_default` tinyint NULL DEFAULT 0 COMMENT '是否默认地址',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `customer_id`(`customer_id` ASC) USING BTREE,
  CONSTRAINT `customer_addresses_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer_addresses
-- ----------------------------

-- ----------------------------
-- Table structure for customers
-- ----------------------------
DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `match_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '唯一标识码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '客户名称',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户类型（经销商/其他渠道）',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `match_id`(`match_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 201 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customers
-- ----------------------------
INSERT INTO `customers` VALUES (101, 'Fki958l4Pv', '钱岚', 'lgl4e0HxUj', '10-8137-0490', 'vWaVvpjueC', 123, '2012-04-16 06:59:22');
INSERT INTO `customers` VALUES (102, 'PntO6yCqWW', '徐子异', 'xUqAxhJp2g', '21-613-5670', 'YVyZJWazaS', 9, '2015-05-23 16:28:07');
INSERT INTO `customers` VALUES (103, '5Mm54ld1ss', '江子韬', 'Y9dBKBqbrL', '20-100-6341', 'nJl1784n6y', 84, '2014-07-04 02:04:19');
INSERT INTO `customers` VALUES (104, 'dSl7yzhq2G', '蔡岚', '9k1aN4Ds2V', '10-7685-0504', 'A0HMuwSSti', 121, '2001-07-12 11:31:41');
INSERT INTO `customers` VALUES (105, 'VV4pZ3Jv0a', '史致远', 'eI3ferg9hg', '158-0874-0505', '3VxDYePtWW', 15, '2010-06-27 09:58:16');
INSERT INTO `customers` VALUES (106, 'RVfJxJ3gdf', '苏睿', 'KYZ7yrcMKk', '760-8572-0120', 'KYYZQGHyrf', 38, '2006-05-23 03:10:03');
INSERT INTO `customers` VALUES (107, 'gchL0a0lVV', '黎岚', '4xsOjefVOu', '172-2501-9900', 'mTs2b1h6cj', 94, '2001-06-27 00:00:12');
INSERT INTO `customers` VALUES (108, 'ClEEIpTBQG', '沈睿', 'MlFugfLDTR', '157-3474-7264', 'mGyNP9PPcd', 51, '2014-10-13 18:51:49');
INSERT INTO `customers` VALUES (109, 'pBPc5l9967', '叶睿', 'FGY7lWRUtg', '198-6390-9853', 'lPARwqUBHv', 78, '2025-03-12 04:53:27');
INSERT INTO `customers` VALUES (110, 'RRMULT0kin', '程璐', 'CZxkP7c0dD', '195-9825-6062', 'G8G3KeqMCc', 61, '2022-12-15 00:45:52');
INSERT INTO `customers` VALUES (111, '77Pqetq5xh', '孔子异', 'ibqRf40N9B', '769-7251-3618', 'AQnj23htuc', 6, '2017-08-18 03:31:48');
INSERT INTO `customers` VALUES (112, 'gdXF66ApkB', '朱子韬', '1MQduxQV18', '177-8170-6804', 'dXtZQhHaPe', 22, '2009-04-10 09:24:21');
INSERT INTO `customers` VALUES (113, 'Kkgxs7pRRt', '高晓明', '5uVCA3Eqhm', '144-5822-4484', 'FUC5PHbWGP', 48, '2014-02-10 00:45:41');
INSERT INTO `customers` VALUES (114, 'Iv4MkL6oZe', '周詩涵', 'uQt11kWyDS', '132-3878-1862', 'a10PVYlK3p', 19, '2020-08-08 21:46:48');
INSERT INTO `customers` VALUES (115, 'RL5bt9BweS', '林子韬', 'IPXuLveg1T', '28-879-8005', '8hg9JGfdBM', 83, '2017-05-27 01:59:51');
INSERT INTO `customers` VALUES (116, 'XLpU928Vym', '曹璐', 'uTwhVioCg9', '134-0125-0449', 'EYkYQMdE8i', 66, '2017-02-16 07:26:51');
INSERT INTO `customers` VALUES (117, 'CvfKuXQ8CG', '汤子异', 'mmRXxgUZLW', '131-6085-0000', 'HJydVqHB4e', 69, '2013-04-11 19:50:02');
INSERT INTO `customers` VALUES (118, 'fndqsbDAM3', '汤震南', 'a2y6k3EIYG', '197-6374-8000', 'tmvKA6Y66T', 73, '2011-11-28 23:56:44');
INSERT INTO `customers` VALUES (119, 'MinksGd5mT', '汪杰宏', 'jigAzuimmC', '139-6972-4086', '48s2pDlQUV', 6, '2015-09-22 14:41:22');
INSERT INTO `customers` VALUES (120, 'aFRqDfeUdB', '郭秀英', 'CQGzpIl11i', '755-4719-3374', 'lj6HMGHJp4', 88, '2013-10-07 20:17:07');
INSERT INTO `customers` VALUES (121, '8T4QnGvWiY', '熊秀英', 'e7o8ba4sha', '755-812-3664', 'Rfb0CvmvxA', 24, '2008-07-04 09:49:22');
INSERT INTO `customers` VALUES (122, 'EI6w2X3i1j', '黄致远', 'J6NCNTi3l9', '755-9222-9985', 'kbfYD8okvS', 96, '2010-04-06 15:14:06');
INSERT INTO `customers` VALUES (123, 'Q33nqg0dDB', '夏秀英', 'vhG7tJ9WL8', '755-5302-6819', 'gjobq80UOZ', 118, '2008-09-02 01:59:40');
INSERT INTO `customers` VALUES (124, 'l59rGRme2G', '蒋晓明', '1m9w5mfr8M', '157-3226-4137', 'qvDFoZH9Sg', 80, '2018-11-28 03:54:52');
INSERT INTO `customers` VALUES (125, '5omOkUn9ki', '廖宇宁', 'kxvHhlGi6g', '28-575-4390', 'DV2Ecq4SMT', 9, '2013-03-05 23:39:05');
INSERT INTO `customers` VALUES (126, 'qddgk3Eksd', '任震南', '0hbSGR6an7', '760-447-2542', 'hA408Fevhf', 77, '2025-02-27 16:00:24');
INSERT INTO `customers` VALUES (127, '8783y9pq39', '谭致远', 'kUFNr3ZQIS', '10-9196-8859', 'awT6mDyDAX', 88, '2023-11-04 02:22:12');
INSERT INTO `customers` VALUES (128, 'jh9vhYkBuk', '郑岚', 'rSZHjYIqIy', '184-0678-4743', 'd7TvmvqPdz', 66, '2005-04-21 01:29:45');
INSERT INTO `customers` VALUES (129, '3mHDeYsE9P', '顾致远', 'vSA79agzUW', '20-057-0198', '3O1wIomrzu', 69, '2008-07-02 13:18:18');
INSERT INTO `customers` VALUES (130, 'NVvyCE1kyS', '邹秀英', '76Lq6lFIBO', '10-090-5576', 'KO5BJPDR9s', 96, '2004-06-23 03:01:59');
INSERT INTO `customers` VALUES (131, 'DOWjBEzRNz', '张安琪', 'FEv2KuNq6E', '144-0671-2023', 'KmSutAYSZa', 14, '2003-11-06 14:48:31');
INSERT INTO `customers` VALUES (132, 'x3j8SqBbCj', '郑宇宁', 'O97O0R1rW2', '196-3963-6573', 'iYtBtoM1wT', 64, '2020-08-08 10:53:16');
INSERT INTO `customers` VALUES (133, 'SjXhrz7Wsx', '尹子韬', 'rEd6IkqwrI', '196-0629-4019', '4sQLVAdKpQ', 72, '2004-04-28 15:11:45');
INSERT INTO `customers` VALUES (134, 'Dn0JE3Gjxf', '马秀英', 'ojCm1zm8rU', '149-1909-4445', 'gCwASoVGuE', 29, '2003-06-19 14:18:45');
INSERT INTO `customers` VALUES (135, 'ian7xLfsvh', '史子异', '88if9ro5TF', '193-0918-6477', 'XQMWh8xrEs', 10, '2014-04-30 13:08:23');
INSERT INTO `customers` VALUES (136, '4wg05k99ZP', '毛子韬', 'rjcetBhGYE', '769-7473-5779', 'IELonubALN', 14, '2012-01-08 08:08:15');
INSERT INTO `customers` VALUES (137, 'kzg4ul6jE6', '魏璐', 'QCsZ2khjL2', '177-1838-2589', 'pDBechUSRL', 81, '2006-09-26 22:46:38');
INSERT INTO `customers` VALUES (138, 'iOoN086reU', '顾璐', 'Tv0pOfvL0K', '188-3770-9009', 'fhZJiBfZQo', 74, '2012-03-10 13:08:27');
INSERT INTO `customers` VALUES (139, 'Zo6hAFgUsi', '钱宇宁', 'WOAJigNO0J', '171-3021-0737', 'DaV1lCHaGc', 43, '2001-09-28 10:48:57');
INSERT INTO `customers` VALUES (140, 'apW0pxznyn', '谭震南', 'ookLfYStGq', '188-8764-7749', 'JZFZ6pftg1', 124, '2019-07-07 09:52:24');
INSERT INTO `customers` VALUES (141, 'DIIikrHlUl', '郭秀英', 'HEWUIWeYW0', '755-5744-2232', 'SGUH5zOktw', 93, '2003-05-14 17:28:08');
INSERT INTO `customers` VALUES (142, 'PAyuHTYKbn', '任晓明', 'mtLvZRHiT4', '195-9646-7779', 'hqRmc0RMVF', 103, '2018-09-09 16:04:44');
INSERT INTO `customers` VALUES (143, '1jDIIwv0nB', '袁詩涵', '9KotiZTSDl', '20-322-9733', 'Vx1D1fnbMp', 87, '2017-04-21 19:45:04');
INSERT INTO `customers` VALUES (144, '5yoaPjs9NW', '江子异', 'CGWzKR5Z3H', '171-9743-5504', 'P0f024YpAq', 53, '2002-09-09 07:23:46');
INSERT INTO `customers` VALUES (145, 'gz9JwUqPlE', '周震南', '5w43wdPliX', '150-6086-6391', 'hjlKwYkL7t', 24, '2023-05-27 23:52:09');
INSERT INTO `customers` VALUES (146, '6XXBs8HZQ4', '唐宇宁', 'mjbsZG3hFl', '755-407-0906', 'ksSakUxtK2', 31, '2015-12-26 11:59:08');
INSERT INTO `customers` VALUES (147, 'vCKVLGDfoE', '韦杰宏', 'MGPrOr6wgS', '755-638-4227', 'ckFhHXCsPN', 9, '2021-08-04 19:16:28');
INSERT INTO `customers` VALUES (148, 'GUBeCwO0on', '叶震南', 'vfrGxzFLWp', '20-6787-4104', '2aWIqx49bo', 97, '2002-12-09 05:20:36');
INSERT INTO `customers` VALUES (149, 'rpdNCtuEhy', '周子韬', 'UOPwvdzQt3', '151-4996-5912', 'qCNy3G9vmS', 22, '2023-11-23 16:31:06');
INSERT INTO `customers` VALUES (150, 'YDd9VY0yqv', '曾嘉伦', 'sSOGePysdi', '760-355-3107', 'aNnYqbPPIr', 10, '2024-01-10 16:28:08');
INSERT INTO `customers` VALUES (151, 'CaOI1LYNVH', '李云熙', 'r56b7bAiQZ', '183-3621-6724', 'kBqjgoO2ln', 45, '2004-02-03 12:55:12');
INSERT INTO `customers` VALUES (152, 'll3u3KGCEU', '陆安琪', 'JnbRyqlKTV', '162-8458-2375', 'eNXx4FHzIa', 86, '2004-07-13 06:32:57');
INSERT INTO `customers` VALUES (153, 'UEAqj0xr6e', '林安琪', '85CKYPGcwL', '159-9239-3290', '6xuWJf5sUg', 13, '2003-04-27 08:47:33');
INSERT INTO `customers` VALUES (154, '2dkjJI46wz', '郑杰宏', '943FUbanGg', '136-1002-7041', 'z6ES0YJchx', 71, '2004-10-20 21:11:39');
INSERT INTO `customers` VALUES (155, '3HK40XGP1D', '周子韬', 'XdwiBmtwn8', '151-2490-9332', '3QjCDMMQsg', 92, '2004-11-02 01:11:19');
INSERT INTO `customers` VALUES (156, 'qhgzgIOoDo', '胡詩涵', 'IoI6f81sNH', '132-2549-1263', 'YXbJUjPa4d', 89, '2002-03-12 16:22:39');
INSERT INTO `customers` VALUES (157, '1HAY9xFNdl', '吴杰宏', '3WJIIxSmOJ', '139-0595-9678', 'clN6Og5JZC', 46, '2013-01-10 14:30:06');
INSERT INTO `customers` VALUES (158, '6WW3Ppjiel', '潘子韬', 'l2QSToTebC', '21-8189-5128', 'E0xgIpSnf4', 46, '2012-05-27 12:01:38');
INSERT INTO `customers` VALUES (159, 'oJdpKkQY2k', '龚詩涵', '0HTgzDs0lV', '180-3998-8316', 'Vk3qREA1ji', 30, '2007-04-16 09:50:48');
INSERT INTO `customers` VALUES (160, 'b3fCmY92Bq', '阎詩涵', 'FxpysCX9nB', '135-8739-0887', 'V8FRxB4GbU', 29, '2019-12-26 07:53:27');
INSERT INTO `customers` VALUES (161, 'clWZKmLXMn', '方安琪', 'wNbemcQovj', '28-8646-0881', '5QDFsKH9Cc', 87, '2005-12-14 00:15:53');
INSERT INTO `customers` VALUES (162, 'WuMgeymMwP', '孙致远', 'Z4xO4BTW6f', '21-6334-3820', 'FK3Ijo8fK3', 75, '2009-04-25 02:18:13');
INSERT INTO `customers` VALUES (163, 'WUJkCzNIaX', '叶子韬', 'SqhG9YTvMX', '158-0478-2632', '5c6HCkgvG4', 36, '2005-03-01 20:11:41');
INSERT INTO `customers` VALUES (164, 'Seb46d842C', '武晓明', '6D4vj7X9A2', '28-9328-2567', '0AtybVlkmW', 1, '2003-10-05 10:29:55');
INSERT INTO `customers` VALUES (165, 'NjFzIkYwIn', '曾子韬', 'Q6gNhDJVOD', '10-8043-5996', 'PRKPVeTiUS', 15, '2007-05-07 02:01:05');
INSERT INTO `customers` VALUES (166, 'E27SFNJnFc', '严璐', '5s2cJJzkMZ', '28-2266-2632', '9bgifmTPkh', 62, '2010-11-21 07:01:18');
INSERT INTO `customers` VALUES (167, '1jIQPw6hkr', '吴震南', 'm3ARPhH6Cz', '769-3688-6956', 'zqld4Wrtq5', 89, '2008-06-14 04:54:19');
INSERT INTO `customers` VALUES (168, 'RQUhzEFpOC', '王詩涵', '7EUBjUHjJQ', '191-0887-6978', '6CCaargRxI', 66, '2005-09-25 08:51:36');
INSERT INTO `customers` VALUES (169, 'iZUdC4cDpR', '毛璐', 'Aqme4xUkiW', '191-7651-0143', 'unFZ4f4btR', 95, '2006-11-17 19:48:46');
INSERT INTO `customers` VALUES (170, 'BN4EgKM9tV', '汪晓明', 'EVVfUzP7WW', '150-6233-4388', 'AgMoJSFKQb', 126, '2024-10-05 10:24:05');
INSERT INTO `customers` VALUES (171, 'etMkA8XTJD', '卢睿', 'Kx7so9SuQ1', '184-4458-9140', 'cOv2z9mJcQ', 23, '2022-02-22 19:30:10');
INSERT INTO `customers` VALUES (172, 'CKTPqUUnWI', '张子异', 'cW8M3wn38J', '20-850-3318', 'fVMhCUtXy5', 126, '2014-11-25 17:24:55');
INSERT INTO `customers` VALUES (173, 'Aln7zVGLCf', '唐璐', 'viNuTbivYk', '189-5319-1823', '74WcSA03NB', 124, '2009-02-04 05:47:56');
INSERT INTO `customers` VALUES (174, 'gS2Yn4UhXY', '邵岚', 'uHbsFLk9b1', '10-1107-1315', '2fNYvzStph', 19, '2024-01-29 08:50:08');
INSERT INTO `customers` VALUES (175, '6I0qneafG4', '任安琪', 'iPoq1fJvFD', '10-469-9850', 'zfXWD4mw5p', 46, '2020-07-24 22:36:17');
INSERT INTO `customers` VALUES (176, 'Y4ouNAymEU', '杜宇宁', '9CEgfweKUb', '184-7592-1414', 'JgtJ0OqVc0', 109, '2019-12-24 07:55:49');
INSERT INTO `customers` VALUES (177, 'sv8P7MYxLI', '邹璐', 'bqaFePfPDa', '760-8381-1713', 'F27E5TFP3g', 89, '2008-11-06 18:01:21');
INSERT INTO `customers` VALUES (178, 'mPw6dhM8kC', '赵嘉伦', 'jOpQ8mU9o0', '170-4269-6404', 'h9HcW3xco5', 109, '2018-02-21 21:35:53');
INSERT INTO `customers` VALUES (179, 'V4CB8vkstr', '周致远', 'A7ndzeBZUQ', '760-3894-5592', 'USzId9Kf0I', 9, '2006-08-27 23:43:09');
INSERT INTO `customers` VALUES (180, 'qoh6S7tEJJ', '蒋安琪', 'GLT0oUcltG', '177-6227-0396', 'B2YefMGw50', 56, '2008-09-24 09:14:48');
INSERT INTO `customers` VALUES (181, 'IuKV4sGgPX', '薛岚', 'x1rMHrL6WK', '174-7036-9841', 'ozXx0sAE7o', 63, '2010-11-25 08:08:51');
INSERT INTO `customers` VALUES (182, '6bP2HCZ4RC', '蒋璐', 'd2aqrllR1n', '21-259-8491', 'pVyx9OPaSQ', 26, '2013-12-11 08:17:31');
INSERT INTO `customers` VALUES (183, 'rK3enpoLSj', '常宇宁', '0pvlEupj7e', '760-5075-2078', 'AZr0Kbpr5i', 76, '2012-10-24 23:24:27');
INSERT INTO `customers` VALUES (184, 'jcD96mTsnB', '傅安琪', 'g5b4n9yOsi', '191-9877-6476', 'dmusC8XJLG', 112, '2012-01-20 00:20:54');
INSERT INTO `customers` VALUES (185, 'YbIoQWakBm', '郭云熙', '3D9cvvzd6Y', '159-5759-2696', 'AtZ7rlsyLC', 54, '2000-02-28 21:58:14');
INSERT INTO `customers` VALUES (186, 'XlgpOo9jbS', '邵云熙', '0yV51U9Qci', '153-6244-2478', 'f92lv7ap7r', 24, '2007-09-09 02:19:46');
INSERT INTO `customers` VALUES (187, '0pLtkkXbbp', '韩云熙', 'PxbpRk9aic', '184-0790-2492', 'qI99IpHXjg', 16, '2019-02-14 19:23:51');
INSERT INTO `customers` VALUES (188, '5NiWt1WivJ', '杜子异', 'FkHDg2biZt', '159-7559-8076', 'oY86ZV51T0', 79, '2001-05-31 13:23:11');
INSERT INTO `customers` VALUES (189, '6NiGkoRMOb', '魏晓明', 'wdCn7dTCFJ', '28-1740-0316', '77DCreeki1', 77, '2011-12-21 11:53:31');
INSERT INTO `customers` VALUES (190, 'RrlkI68COH', '方睿', 'Z3Y7ChSXj2', '137-8060-7162', 'iyVI9DHZaF', 28, '2000-06-23 12:19:13');
INSERT INTO `customers` VALUES (191, 'InNLjX4FdZ', '余秀英', 'DvyzzJh4Xb', '140-4663-1431', '6ygaVuKrP1', 126, '2018-02-21 23:49:45');
INSERT INTO `customers` VALUES (192, 'ODb2mbEXAD', '苏子韬', 'qE2P4pPiYc', '21-8772-3522', 'MbJOWiFm7D', 124, '2004-04-09 21:28:10');
INSERT INTO `customers` VALUES (193, 'Og3nUDp3nN', '卢致远', 'iFwWRNXbKG', '20-5387-1892', 'IGsflVeSXl', 24, '2010-01-06 00:53:04');
INSERT INTO `customers` VALUES (194, 'LuOyW2HVGa', '贾震南', 'cWQrxwABOI', '28-5620-5657', 'ytOp7WK2T7', 119, '2023-03-02 20:25:09');
INSERT INTO `customers` VALUES (195, 'ft9jStgeHP', '杜秀英', 'EhFrK9CBjB', '760-418-8573', 'ZqMjiPioWy', 47, '2018-04-30 16:51:53');
INSERT INTO `customers` VALUES (196, 'UjRb4QbnRM', '周杰宏', 'jprX3y7bKW', '186-2271-4484', 'XUUxPgvvlD', 22, '2005-02-25 04:46:20');
INSERT INTO `customers` VALUES (197, 'xxvA73YFfV', '梁詩涵', 'eHrtZ5JMZN', '141-7020-8809', 'kBgnJ615T5', 3, '2024-12-24 20:32:17');
INSERT INTO `customers` VALUES (198, 'jzB8cogftB', '贾安琪', 'j6eoVLVofm', '28-7747-5167', 'j3YgenyZPD', 85, '2002-03-22 18:40:02');
INSERT INTO `customers` VALUES (199, 'baJ8EDOWG6', '袁致远', 'avKfzOb5uu', '20-209-7695', 'WrfrhE2C4E', 62, '2019-05-08 06:37:56');
INSERT INTO `customers` VALUES (200, 'NCjajHJnz3', '汤嘉伦', 'lFnNnZZrbe', '177-3060-2885', 'XjEpOGaKm2', 24, '2006-01-20 05:59:35');

-- ----------------------------
-- Table structure for dealer_quota_logs
-- ----------------------------
DROP TABLE IF EXISTS `dealer_quota_logs`;
CREATE TABLE `dealer_quota_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `dealer_id` bigint NOT NULL COMMENT '经销商ID',
  `change_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '变动类型，如分配、扣减、归还',
  `change_amount` decimal(18, 2) NOT NULL COMMENT '变动额度',
  `before_amount` decimal(18, 2) NULL DEFAULT NULL COMMENT '变动前额度',
  `after_amount` decimal(18, 2) NULL DEFAULT NULL COMMENT '变动后额度',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `dealer_id`(`dealer_id` ASC) USING BTREE,
  CONSTRAINT `dealer_quota_logs_ibfk_1` FOREIGN KEY (`dealer_id`) REFERENCES `dealers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dealer_quota_logs
-- ----------------------------

-- ----------------------------
-- Table structure for dealers
-- ----------------------------
DROP TABLE IF EXISTS `dealers`;
CREATE TABLE `dealers`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `match_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '唯一标识码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '经销商名称',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `quota` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '库存额度',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `match_id`(`match_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dealers
-- ----------------------------
INSERT INTO `dealers` VALUES (1, 'M123456', '张三', '张三', '1888888888', 12331.00);
INSERT INTO `dealers` VALUES (2, 'M714596', '史致远', '史致远', '1888888888', 9343.94);
INSERT INTO `dealers` VALUES (3, 'M070978', '钱子异', '钱子异', '1888888888', 6137.29);
INSERT INTO `dealers` VALUES (4, 'M329883', '邱宇宁', '邱宇宁', '1888888888', 8758.85);
INSERT INTO `dealers` VALUES (5, 'M891822', '曾秀英', '曾秀英', '1888888888', 6539.50);
INSERT INTO `dealers` VALUES (6, 'M053349', '何詩涵', '何詩涵', '1888888888', 8926.22);
INSERT INTO `dealers` VALUES (7, 'M263476', '尹璐', '尹璐', '1888888888', 9012.20);
INSERT INTO `dealers` VALUES (8, 'M009774', '刘子韬', '刘子韬', '1888888888', 5310.98);
INSERT INTO `dealers` VALUES (9, 'M696900', '马詩涵', '马詩涵', '1888888888', 9271.61);
INSERT INTO `dealers` VALUES (10, 'M170712', '于致远', '于致远', '1888888888', 7596.43);
INSERT INTO `dealers` VALUES (11, 'M934436', '陶致远', '陶致远', '1888888888', 8358.59);
INSERT INTO `dealers` VALUES (12, 'M592147', '唐璐', '唐璐', '1888888888', 9901.10);
INSERT INTO `dealers` VALUES (13, 'M943108', '林震南', '林震南', '1888888888', 6953.48);
INSERT INTO `dealers` VALUES (14, 'M040689', '秦云熙', '秦云熙', '1888888888', 9231.33);
INSERT INTO `dealers` VALUES (15, 'M072467', '余云熙', '余云熙', '1888888888', 9622.72);
INSERT INTO `dealers` VALUES (16, 'M004954', '李睿', '李睿', '1888888888', 8419.61);
INSERT INTO `dealers` VALUES (17, 'M522723', '任詩涵', '任詩涵', '1888888888', 5759.40);
INSERT INTO `dealers` VALUES (18, 'M877839', '曾睿', '曾睿', '1888888888', 5114.14);
INSERT INTO `dealers` VALUES (19, 'M440096', '何宇宁', '何宇宁', '1888888888', 6906.13);
INSERT INTO `dealers` VALUES (20, 'M12312312', '杨秘密', '杨秘密', '1888888888', 0.00);
INSERT INTO `dealers` VALUES (21, 'M12321312321', '牛牛', '牛牛', '1888888888', 0.00);
INSERT INTO `dealers` VALUES (22, 'M123231', '牛牛11', '牛牛11', '1888888888', 0.00);

-- ----------------------------
-- Table structure for factories
-- ----------------------------
DROP TABLE IF EXISTS `factories`;
CREATE TABLE `factories`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工厂名称',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工厂地址',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of factories
-- ----------------------------
INSERT INTO `factories` VALUES (1, '武汉', '武汉', '张三', '12345678911');
INSERT INTO `factories` VALUES (2, '长沙', '上沙', '李四', '12321312312');
INSERT INTO `factories` VALUES (3, '广州', '广州', '王五', '18858642354');
INSERT INTO `factories` VALUES (4, '刘家大院', '哈哈哈哈', '刘老板', '1236786786876');

-- ----------------------------
-- Table structure for factory_stock_logs
-- ----------------------------
DROP TABLE IF EXISTS `factory_stock_logs`;
CREATE TABLE `factory_stock_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `factory_id` bigint NOT NULL COMMENT '工厂ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关订单编号',
  `change_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '变动类型，如入库、出库、锁定、解锁、退货、损耗等',
  `change_amount` decimal(18, 2) NOT NULL COMMENT '变动数量',
  `before_amount` decimal(18, 2) NULL DEFAULT NULL COMMENT '变动前库存',
  `after_amount` decimal(18, 2) NULL DEFAULT NULL COMMENT '变动后库存',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `factory_id`(`factory_id` ASC) USING BTREE,
  INDEX `product_id`(`product_id` ASC) USING BTREE,
  CONSTRAINT `factory_stock_logs_ibfk_1` FOREIGN KEY (`factory_id`) REFERENCES `factories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `factory_stock_logs_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products_spu` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of factory_stock_logs
-- ----------------------------

-- ----------------------------
-- Table structure for factory_stocks
-- ----------------------------
DROP TABLE IF EXISTS `factory_stocks`;
CREATE TABLE `factory_stocks`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `factory_id` bigint NOT NULL COMMENT '工厂ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '实际库存',
  `locked_quantity` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '已锁定库存',
  `warning_threshold` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '库存预警阈值',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `factory_id`(`factory_id` ASC) USING BTREE,
  INDEX `product_id`(`product_id` ASC) USING BTREE,
  CONSTRAINT `factory_stocks_ibfk_1` FOREIGN KEY (`factory_id`) REFERENCES `factories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 101 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of factory_stocks
-- ----------------------------
INSERT INTO `factory_stocks` VALUES (1, 3, 10024, 475.00, 483.00, 613.00);
INSERT INTO `factory_stocks` VALUES (2, 2, 10018, 570.00, 155.00, 134.00);
INSERT INTO `factory_stocks` VALUES (3, 2, 10030, 743.00, 459.00, 1000.00);
INSERT INTO `factory_stocks` VALUES (4, 3, 10003, 67.00, 287.00, 554.00);
INSERT INTO `factory_stocks` VALUES (5, 3, 10005, 177.00, 55.00, 590.00);
INSERT INTO `factory_stocks` VALUES (6, 3, 10006, 312.00, 959.00, 887.00);
INSERT INTO `factory_stocks` VALUES (7, 1, 10001, 608.00, 932.00, 163.00);
INSERT INTO `factory_stocks` VALUES (8, 3, 10030, 797.00, 658.00, 868.00);
INSERT INTO `factory_stocks` VALUES (9, 3, 10004, 863.00, 220.00, 852.00);
INSERT INTO `factory_stocks` VALUES (10, 1, 10001, 958.00, 838.00, 664.00);
INSERT INTO `factory_stocks` VALUES (11, 3, 10017, 796.00, 376.00, 601.00);
INSERT INTO `factory_stocks` VALUES (12, 2, 10016, 932.00, 803.00, 179.00);
INSERT INTO `factory_stocks` VALUES (13, 1, 10014, 935.00, 123.00, 979.00);
INSERT INTO `factory_stocks` VALUES (14, 1, 10020, 665.00, 891.00, 936.00);
INSERT INTO `factory_stocks` VALUES (15, 3, 10011, 113.00, 158.00, 44.00);
INSERT INTO `factory_stocks` VALUES (16, 3, 10018, 937.00, 307.00, 264.00);
INSERT INTO `factory_stocks` VALUES (17, 3, 10015, 857.00, 133.00, 435.00);
INSERT INTO `factory_stocks` VALUES (18, 1, 10020, 972.00, 610.00, 490.00);
INSERT INTO `factory_stocks` VALUES (19, 3, 10008, 940.00, 801.00, 310.00);
INSERT INTO `factory_stocks` VALUES (20, 3, 10012, 619.00, 287.00, 698.00);
INSERT INTO `factory_stocks` VALUES (21, 1, 10027, 763.00, 451.00, 753.00);
INSERT INTO `factory_stocks` VALUES (22, 1, 10002, 767.00, 934.00, 337.00);
INSERT INTO `factory_stocks` VALUES (23, 3, 10001, 932.00, 622.00, 236.00);
INSERT INTO `factory_stocks` VALUES (24, 1, 10028, 398.00, 960.00, 300.00);
INSERT INTO `factory_stocks` VALUES (25, 2, 10020, 683.00, 358.00, 270.00);
INSERT INTO `factory_stocks` VALUES (26, 1, 10030, 443.00, 200.00, 158.00);
INSERT INTO `factory_stocks` VALUES (27, 3, 10018, 978.00, 413.00, 1.00);
INSERT INTO `factory_stocks` VALUES (28, 1, 10018, 704.00, 219.00, 946.00);
INSERT INTO `factory_stocks` VALUES (29, 1, 10007, 695.00, 284.00, 393.00);
INSERT INTO `factory_stocks` VALUES (30, 2, 10006, 382.00, 970.00, 275.00);
INSERT INTO `factory_stocks` VALUES (31, 2, 10028, 455.00, 816.00, 57.00);
INSERT INTO `factory_stocks` VALUES (32, 2, 10028, 448.00, 679.00, 668.00);
INSERT INTO `factory_stocks` VALUES (33, 2, 10029, 589.00, 159.00, 751.00);
INSERT INTO `factory_stocks` VALUES (34, 1, 10005, 265.00, 838.00, 390.00);
INSERT INTO `factory_stocks` VALUES (35, 1, 10007, 177.00, 307.00, 702.00);
INSERT INTO `factory_stocks` VALUES (36, 1, 10006, 878.00, 305.00, 894.00);
INSERT INTO `factory_stocks` VALUES (37, 2, 10004, 796.00, 837.00, 691.00);
INSERT INTO `factory_stocks` VALUES (38, 1, 10021, 801.00, 975.00, 368.00);
INSERT INTO `factory_stocks` VALUES (39, 1, 10008, 289.00, 167.00, 840.00);
INSERT INTO `factory_stocks` VALUES (40, 1, 10005, 641.00, 291.00, 410.00);
INSERT INTO `factory_stocks` VALUES (41, 1, 10004, 370.00, 208.00, 819.00);
INSERT INTO `factory_stocks` VALUES (42, 2, 10022, 329.00, 328.00, 601.00);
INSERT INTO `factory_stocks` VALUES (43, 2, 10004, 33.00, 722.00, 507.00);
INSERT INTO `factory_stocks` VALUES (44, 1, 10011, 276.00, 504.00, 567.00);
INSERT INTO `factory_stocks` VALUES (45, 2, 10019, 830.00, 665.00, 952.00);
INSERT INTO `factory_stocks` VALUES (46, 1, 10028, 29.00, 856.00, 756.00);
INSERT INTO `factory_stocks` VALUES (47, 3, 10004, 936.00, 885.00, 747.00);
INSERT INTO `factory_stocks` VALUES (48, 2, 10004, 532.00, 716.00, 615.00);
INSERT INTO `factory_stocks` VALUES (49, 2, 10008, 912.00, 693.00, 883.00);
INSERT INTO `factory_stocks` VALUES (50, 2, 10025, 469.00, 776.00, 917.00);
INSERT INTO `factory_stocks` VALUES (51, 3, 10015, 517.00, 631.00, 741.00);
INSERT INTO `factory_stocks` VALUES (52, 1, 10021, 881.00, 992.00, 276.00);
INSERT INTO `factory_stocks` VALUES (53, 1, 10023, 79.00, 914.00, 420.00);
INSERT INTO `factory_stocks` VALUES (54, 2, 10015, 436.00, 583.00, 483.00);
INSERT INTO `factory_stocks` VALUES (55, 3, 10019, 850.00, 675.00, 97.00);
INSERT INTO `factory_stocks` VALUES (56, 1, 10011, 627.00, 462.00, 126.00);
INSERT INTO `factory_stocks` VALUES (57, 2, 10013, 991.00, 628.00, 614.00);
INSERT INTO `factory_stocks` VALUES (58, 1, 10026, 1.00, 393.00, 431.00);
INSERT INTO `factory_stocks` VALUES (59, 2, 10026, 858.00, 324.00, 414.00);
INSERT INTO `factory_stocks` VALUES (60, 1, 10024, 200.00, 4.00, 229.00);
INSERT INTO `factory_stocks` VALUES (61, 1, 10018, 257.00, 869.00, 375.00);
INSERT INTO `factory_stocks` VALUES (62, 2, 10027, 500.00, 2.00, 824.00);
INSERT INTO `factory_stocks` VALUES (63, 3, 10021, 458.00, 880.00, 117.00);
INSERT INTO `factory_stocks` VALUES (64, 1, 10013, 104.00, 637.00, 213.00);
INSERT INTO `factory_stocks` VALUES (65, 1, 10020, 77.00, 919.00, 734.00);
INSERT INTO `factory_stocks` VALUES (66, 2, 10015, 682.00, 845.00, 965.00);
INSERT INTO `factory_stocks` VALUES (67, 1, 10023, 480.00, 750.00, 422.00);
INSERT INTO `factory_stocks` VALUES (68, 1, 10002, 841.00, 73.00, 763.00);
INSERT INTO `factory_stocks` VALUES (69, 1, 10024, 203.00, 352.00, 744.00);
INSERT INTO `factory_stocks` VALUES (70, 3, 10025, 347.00, 93.00, 857.00);
INSERT INTO `factory_stocks` VALUES (71, 2, 10008, 683.00, 834.00, 149.00);
INSERT INTO `factory_stocks` VALUES (72, 1, 10019, 778.00, 207.00, 630.00);
INSERT INTO `factory_stocks` VALUES (73, 2, 10015, 986.00, 981.00, 120.00);
INSERT INTO `factory_stocks` VALUES (74, 1, 10024, 53.00, 331.00, 83.00);
INSERT INTO `factory_stocks` VALUES (75, 2, 10011, 227.00, 496.00, 998.00);
INSERT INTO `factory_stocks` VALUES (76, 1, 10013, 550.00, 441.00, 215.00);
INSERT INTO `factory_stocks` VALUES (77, 1, 10007, 489.00, 578.00, 690.00);
INSERT INTO `factory_stocks` VALUES (78, 1, 10026, 765.00, 660.00, 737.00);
INSERT INTO `factory_stocks` VALUES (79, 3, 10010, 157.00, 344.00, 76.00);
INSERT INTO `factory_stocks` VALUES (80, 1, 10030, 395.00, 661.00, 474.00);
INSERT INTO `factory_stocks` VALUES (81, 2, 10018, 320.00, 305.00, 299.00);
INSERT INTO `factory_stocks` VALUES (82, 1, 10029, 860.00, 136.00, 35.00);
INSERT INTO `factory_stocks` VALUES (83, 1, 10011, 275.00, 101.00, 672.00);
INSERT INTO `factory_stocks` VALUES (84, 3, 10008, 518.00, 177.00, 1.00);
INSERT INTO `factory_stocks` VALUES (85, 2, 10011, 932.00, 514.00, 567.00);
INSERT INTO `factory_stocks` VALUES (86, 2, 10003, 858.00, 605.00, 950.00);
INSERT INTO `factory_stocks` VALUES (87, 1, 10008, 507.00, 973.00, 50.00);
INSERT INTO `factory_stocks` VALUES (88, 3, 10006, 760.00, 77.00, 92.00);
INSERT INTO `factory_stocks` VALUES (89, 1, 10014, 195.00, 382.00, 206.00);
INSERT INTO `factory_stocks` VALUES (90, 1, 10015, 82.00, 635.00, 259.00);
INSERT INTO `factory_stocks` VALUES (91, 3, 10011, 546.00, 828.00, 354.00);
INSERT INTO `factory_stocks` VALUES (92, 3, 10001, 935.00, 40.00, 407.00);
INSERT INTO `factory_stocks` VALUES (93, 3, 10020, 848.00, 78.00, 779.00);
INSERT INTO `factory_stocks` VALUES (94, 3, 10026, 814.00, 227.00, 512.00);
INSERT INTO `factory_stocks` VALUES (95, 2, 10023, 802.00, 206.00, 209.00);
INSERT INTO `factory_stocks` VALUES (96, 1, 10020, 276.00, 718.00, 34.00);
INSERT INTO `factory_stocks` VALUES (97, 2, 10012, 565.00, 901.00, 193.00);
INSERT INTO `factory_stocks` VALUES (98, 2, 10019, 430.00, 597.00, 245.00);
INSERT INTO `factory_stocks` VALUES (99, 3, 10022, 502.00, 449.00, 755.00);
INSERT INTO `factory_stocks` VALUES (100, 1, 10026, 277.00, 470.00, 947.00);

-- ----------------------------
-- Table structure for freight_logs
-- ----------------------------
DROP TABLE IF EXISTS `freight_logs`;
CREATE TABLE `freight_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `dealer_id` bigint NOT NULL COMMENT '经销商ID',
  `amount` decimal(18, 2) NOT NULL COMMENT '运费金额',
  `collected` tinyint NOT NULL DEFAULT 0 COMMENT '是否已收取：0=未收取，1=已收取',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_dealer_id`(`dealer_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '运费日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of freight_logs
-- ----------------------------

-- ----------------------------
-- Table structure for freight_rules
-- ----------------------------
DROP TABLE IF EXISTS `freight_rules`;
CREATE TABLE `freight_rules`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `freight_amount` decimal(18, 2) NOT NULL COMMENT '运费金额',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `product_id`(`product_id` ASC) USING BTREE,
  CONSTRAINT `freight_rules_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products_spu` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of freight_rules
-- ----------------------------

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '通知类型',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '通知内容',
  `is_read` tinyint NULL DEFAULT 0 COMMENT '是否已读',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notifications
-- ----------------------------

-- ----------------------------
-- Table structure for order_items
-- ----------------------------
DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(18, 2) NOT NULL COMMENT '数量',
  `unit_price` decimal(18, 2) NOT NULL COMMENT '单价',
  `total_price` decimal(18, 2) NOT NULL COMMENT '总价',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_product_id`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_items
-- ----------------------------

-- ----------------------------
-- Table structure for order_items_history
-- ----------------------------
DROP TABLE IF EXISTS `order_items_history`;
CREATE TABLE `order_items_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(18, 2) NOT NULL COMMENT '商品数量',
  `unit_price` decimal(18, 2) NOT NULL COMMENT '单价',
  `total_price` decimal(18, 2) NOT NULL COMMENT '总价',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE,
  INDEX `product_id`(`product_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_items_history
-- ----------------------------

-- ----------------------------
-- Table structure for order_logs
-- ----------------------------
DROP TABLE IF EXISTS `order_logs`;
CREATE TABLE `order_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作类型',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_logs
-- ----------------------------

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单编号',
  `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发件人姓名',
  `dealer_id` bigint NULL DEFAULT NULL COMMENT '经销商ID',
  `factory_id` bigint NULL DEFAULT NULL COMMENT '工厂ID',
  `status` tinyint NOT NULL COMMENT '订单状态：1=待审核，2=已审核待发货，3=已发货，4=已完成，5=已取消',
  `total_amount` decimal(18, 2) NOT NULL COMMENT '订单总金额',
  `freight` decimal(18, 2) NOT NULL COMMENT '运费',
  `receiver_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人电话',
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货地址',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '修改人ID',
  `audit_by` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `audit_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `audit_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核备注',
  `order_date` datetime NOT NULL COMMENT '订单日期',
  `delivery_type` tinyint NULL DEFAULT NULL COMMENT '快递类型：1=自提，2=到付，3=现付',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `import_id` bigint NULL DEFAULT NULL COMMENT '导入记录ID',
  `quota_deducted` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '已扣除的库存额度',
  `quota_returned` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '已归还的库存额度',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_sender_name`(`sender_name` ASC) USING BTREE,
  INDEX `idx_order_date`(`order_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------

-- ----------------------------
-- Table structure for permissions
-- ----------------------------
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限名称',
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限编码，如order.create',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限描述',
  `type` int NOT NULL DEFAULT 1 COMMENT '权限类型 1：菜单，2：按钮，3：接口',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE,
  UNIQUE INDEX `code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of permissions
-- ----------------------------
INSERT INTO `permissions` VALUES (1, '创建用户', 'user.create', '创建用户', 1);
INSERT INTO `permissions` VALUES (2, '查询用户', 'user.select', 'cx', 1);
INSERT INTO `permissions` VALUES (3, '更新用户', 'user.update', 'up', 1);
INSERT INTO `permissions` VALUES (4, '删除用户', 'user.delete', 'de', 1);
INSERT INTO `permissions` VALUES (5, '报表权限', 'report.select', '只有财务能查看', 3);

-- ----------------------------
-- Table structure for product_categories
-- ----------------------------
DROP TABLE IF EXISTS `product_categories`;
CREATE TABLE `product_categories`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父级分类ID',
  `level` tinyint NULL DEFAULT 1 COMMENT '分类级别：1=一级分类, 2=二级分类',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product_categories
-- ----------------------------
INSERT INTO `product_categories` VALUES (1, '个护清洁', 0, 1, '2020-07-24 21:33:17');
INSERT INTO `product_categories` VALUES (2, '美妆护肤', 0, 1, '2010-07-19 15:51:03');
INSERT INTO `product_categories` VALUES (3, '洗发护发', 1, 2, '2025-03-28 00:07:25');
INSERT INTO `product_categories` VALUES (4, '身体护理', 1, 2, '2010-02-06 11:46:02');
INSERT INTO `product_categories` VALUES (5, '纸巾湿巾', 1, 2, '2024-05-11 12:52:17');
INSERT INTO `product_categories` VALUES (6, '口腔护理', 1, 2, '2009-10-23 02:12:17');
INSERT INTO `product_categories` VALUES (7, '女性护理', 1, 2, '2016-03-21 21:12:23');
INSERT INTO `product_categories` VALUES (8, '衣物清洁', 1, 2, '2017-03-06 07:30:57');
INSERT INTO `product_categories` VALUES (9, '家庭清洁', 1, 2, '2022-04-16 00:18:36');
INSERT INTO `product_categories` VALUES (10, '驱蚊驱虫', 1, 2, '2008-10-12 14:51:54');
INSERT INTO `product_categories` VALUES (11, '面部护肤', 2, 2, '2025-06-08 22:01:05');
INSERT INTO `product_categories` VALUES (12, '彩妆', 2, 2, '2025-06-08 22:01:15');
INSERT INTO `product_categories` VALUES (13, '香水', 2, 2, '2025-06-08 22:01:38');
INSERT INTO `product_categories` VALUES (14, '美妆', 2, 2, '2025-06-08 22:01:46');
INSERT INTO `product_categories` VALUES (15, '洗发水', 3, 3, '2025-06-13 11:31:59');
INSERT INTO `product_categories` VALUES (16, '护发素', 3, 3, '2025-06-13 11:32:11');
INSERT INTO `product_categories` VALUES (17, '面膜', 11, 3, '2025-06-13 11:32:54');
INSERT INTO `product_categories` VALUES (18, '保湿水', 11, 3, '2025-06-13 11:34:15');

-- ----------------------------
-- Table structure for products_sku
-- ----------------------------
DROP TABLE IF EXISTS `products_sku`;
CREATE TABLE `products_sku`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `spu_id` bigint NOT NULL COMMENT 'SPU ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'SKU编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'SKU名称',
  `specs` json NULL COMMENT '规格属性JSON，如{\"颜色\":\"红色\",\"尺寸\":\"XL\"}',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '计量单位',
  `price` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '销售价格',
  `cost_price` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '成本价',
  `special_rule` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '特殊计量规则，如3件扣1',
  `quota_deduct_ratio` decimal(18, 2) NULL DEFAULT 1.00 COMMENT '库存额度扣除比例',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_products_sku_code`(`code` ASC) USING BTREE,
  INDEX `idx_products_sku_spu`(`spu_id` ASC) USING BTREE,
  CONSTRAINT `fk_products_sku_spu` FOREIGN KEY (`spu_id`) REFERENCES `products_spu` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 101 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品SKU表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of products_sku
-- ----------------------------
INSERT INTO `products_sku` VALUES (1, 2, 'RAEZB3547526553', '烟酰胺面膜', '{\"key60\": 350}', '4MWDT4uUOz', 265.00, 183.63, 'dkwJjzuO1X', 457.62, 1, 493, '2022-04-11 14:13:34', '2000-11-11 13:52:40');
INSERT INTO `products_sku` VALUES (2, 21, 'HJAJM8502285324', '洗衣液', '{\"key4\": 819, \"key5\": 67, \"key8\": 2, \"key9\": 2, \"key11\": 173, \"key983\": 24}', '9f9sUhZIv6', 103.00, 317.09, 'K8JVi4O8II', 946.89, 0, 791, '2008-07-28 05:33:40', '2008-08-26 16:23:29');
INSERT INTO `products_sku` VALUES (3, 3, 'BUMOB6454405514', '卫生巾', '{\"key3\": 72}', 'lLTIYFcqBn', 354.00, 915.27, 'KpiQXEyih9', 859.53, 1, 149, '2004-09-29 14:58:27', '2017-12-06 17:23:25');
INSERT INTO `products_sku` VALUES (4, 15, 'SBUYC6174435520', '防晒喷雾/5瓶', '{\"key3\": 290, \"key6\": 929, \"key21\": 7, \"key36\": 2, \"key430\": 703, \"key847\": 9}', 'HOeZBhWxNl', 928.00, 405.16, 'Hte8US489D', 338.73, 0, 717, '2023-06-10 22:13:38', '2000-10-17 23:05:00');
INSERT INTO `products_sku` VALUES (5, 21, 'VIUKX5262286283', '24K金/保湿霜', '{\"key27\": 8, \"key81\": 657}', '67pYiTxXpv', 173.00, 944.14, 'SKV9j4iVP6', 307.61, 0, 509, '2013-02-14 02:32:04', '2021-08-05 13:54:44');
INSERT INTO `products_sku` VALUES (6, 15, 'CWGQM7724633476', '抗皱面膜', '{\"key2\": 60, \"key4\": 537, \"key21\": 1}', '4fS4g40PcL', 554.00, 602.04, 'UToZQk6SWL', 488.65, 0, 189, '2009-08-08 14:06:44', '2006-03-20 01:06:33');
INSERT INTO `products_sku` VALUES (7, 10, 'ZAGWE5158672665', '24K金/精华', '{\"key2\": 5, \"key8\": 2}', 'oC5dzH8xSS', 163.00, 76.79, 'qcb37DzGnu', 242.35, 1, 231, '2006-01-15 04:16:04', '2006-10-10 03:48:50');
INSERT INTO `products_sku` VALUES (8, 20, 'RSRNV5825177362', '24K金/乳', '{\"key7\": 973, \"key14\": 908, \"key124\": 602, \"key715\": 9}', '9eHfC7vNwM', 703.00, 296.21, '0QrYyiDkQw', 633.29, 0, 658, '2024-03-19 06:29:22', '2011-02-25 23:18:36');
INSERT INTO `products_sku` VALUES (9, 19, 'ITFNS4107813820', '防晒喷雾/5瓶', '{\"key9\": 9, \"key33\": 263}', 'x5gcnl2Q2W', 491.00, 704.32, 'p8PPiVVVuj', 825.59, 0, 741, '2025-02-06 16:35:09', '2013-05-07 08:39:28');
INSERT INTO `products_sku` VALUES (10, 3, 'XIVDT5838341254', '抗皱霜', '{\"key4\": 771, \"key6\": 467, \"key8\": 4, \"key57\": 52, \"key148\": 409, \"key324\": 37}', 'IUW1vOXqmY', 880.00, 358.21, 'aJWEa9ZbsO', 524.59, 0, 483, '2001-03-12 06:17:19', '2023-03-28 23:02:28');
INSERT INTO `products_sku` VALUES (11, 21, 'ILDEM0163237388', '防晒霜', '{\"key85\": 7, \"key416\": 1, \"key624\": 4}', 'HnO3yfklXT', 74.00, 736.12, 'SFQ58GXUqn', 829.43, 0, 250, '2021-07-13 21:44:33', '2014-08-11 09:54:24');
INSERT INTO `products_sku` VALUES (12, 23, 'CQCTW7376334220', '冰膜', '{\"key242\": 601, \"key347\": 56, \"key483\": 4, \"key709\": 8, \"key873\": 9}', 'edeqSPZCCr', 71.00, 649.75, 'RN7ILDAYhX', 100.87, 1, 151, '2011-02-15 06:06:05', '2000-01-31 21:52:49');
INSERT INTO `products_sku` VALUES (13, 22, 'FBVFF8866244253', '24K金/精华', '{\"key85\": 5, \"key94\": 108, \"key499\": 414}', 'H4y6gbzoxT', 931.00, 164.13, '6gw3XogiON', 695.19, 0, 596, '2001-09-01 06:25:34', '2007-01-09 08:05:10');
INSERT INTO `products_sku` VALUES (14, 8, 'WNPCR7578700376', '凝时抗皱焕肤套盒', '{\"key4\": 11, \"key8\": 76, \"key68\": 154, \"key125\": 584}', '4rGkJlAX30', 705.00, 52.64, 'H7OFM428PL', 377.84, 1, 243, '2000-02-12 07:01:25', '2013-05-23 23:44:22');
INSERT INTO `products_sku` VALUES (15, 7, 'RJICM0383566605', '抗皱霜', '{\"key5\": 593, \"key14\": 6, \"key38\": 8, \"key95\": 76}', 'E6TMuJhlsq', 6.00, 139.20, 'RoHS4slpNW', 505.33, 1, 659, '2018-04-16 04:59:05', '2007-04-11 12:55:16');
INSERT INTO `products_sku` VALUES (16, 6, 'HRFPH4114758227', '24K金/精华', '{\"key352\": 7}', 'Wt8RLvSKsE', 877.00, 15.16, '55zbBEij72', 811.48, 0, 542, '2009-04-09 15:15:55', '2002-02-23 07:57:39');
INSERT INTO `products_sku` VALUES (17, 13, 'UWKCM3748870188', '抗皱水', '{\"key3\": 73, \"key7\": 1, \"key83\": 10, \"key112\": 23, \"key606\": 78}', 'GPOXwN9Kps', 545.00, 491.21, 'ckQ7IoNs91', 537.08, 1, 654, '2019-06-28 21:26:06', '2020-09-05 11:53:16');
INSERT INTO `products_sku` VALUES (18, 21, 'SUMQG1214187007', '24K金/水', '{\"key2\": 15, \"key11\": 45, \"key73\": 82, \"key80\": 5, \"key220\": 51, \"key803\": 888}', '2Mb4o1xLfE', 301.00, 129.06, 'hFzCotLEBy', 442.05, 1, 230, '2005-04-19 13:33:24', '2015-05-18 13:20:13');
INSERT INTO `products_sku` VALUES (19, 16, 'OXIVV5682176141', '24K金/精华', '{\"key2\": 51, \"key7\": 54, \"key189\": 73, \"key307\": 7, \"key656\": 8}', 'HRkHhDmDjX', 85.00, 630.46, 'A0OKDls99y', 280.75, 1, 75, '2022-06-10 15:12:32', '2024-05-26 20:31:29');
INSERT INTO `products_sku` VALUES (20, 3, 'LVRQM0376217881', '24K金/水', '{\"key181\": 36}', 'IxkDTrATye', 850.00, 819.56, 'MDcDgDwhPj', 45.52, 0, 900, '2020-04-06 21:43:17', '2021-04-01 02:00:57');
INSERT INTO `products_sku` VALUES (21, 26, 'QNXIT5042228638', '牙膏', '{\"key8\": 140, \"key149\": 970, \"key808\": 93}', 'eL31jtEF3v', 278.00, 390.49, 'ULIKMZwnXl', 354.38, 1, 604, '2013-03-18 19:10:47', '2001-12-15 17:10:56');
INSERT INTO `products_sku` VALUES (22, 2, 'AHOBM1438620022', '柔顺护发膜', '{\"key49\": 17, \"key497\": 424, \"key593\": 6}', 'kwM3Q7D6vv', 445.00, 734.54, 'eL4ibR86si', 853.69, 1, 349, '2024-11-23 03:18:28', '2005-04-14 21:28:29');
INSERT INTO `products_sku` VALUES (23, 25, 'NBJLS3711265851', '柔顺护发膜', '{\"key94\": 9, \"key956\": 12}', 'YbsnwoWNTn', 902.00, 767.50, '8iJNOj0rEY', 147.86, 1, 771, '2016-02-13 08:31:31', '2022-06-24 23:38:34');
INSERT INTO `products_sku` VALUES (24, 26, 'UWJLU4832366528', '气垫BB', '{\"key1\": 70, \"key6\": 126, \"key30\": 513, \"key551\": 2}', 'SeA8eP7LH3', 880.00, 591.32, 'W3Z7Ep0lyD', 4.59, 1, 684, '2016-03-16 14:05:57', '2016-04-17 16:20:27');
INSERT INTO `products_sku` VALUES (25, 10, 'ZOMDQ7353018377', '卫生巾', '{\"key3\": 655, \"key81\": 4, \"key308\": 49}', 'DB7ccqbXjf', 630.00, 529.18, '7eSpVOJ4vg', 92.60, 0, 662, '2015-10-29 04:07:37', '2002-05-04 03:46:31');
INSERT INTO `products_sku` VALUES (26, 29, 'HBJZL1800643073', '蜜都安睡裤', '{\"key78\": 21, \"key727\": 229}', 'qRZMVpJUDe', 444.00, 926.14, 'J5qSsjN5xd', 334.66, 0, 77, '2002-05-29 12:08:12', '2021-02-20 18:46:42');
INSERT INTO `products_sku` VALUES (27, 26, 'BQQMX7131683015', '补水喷雾', '{\"key62\": 71, \"key398\": 1}', 'i8TfrtjZav', 858.00, 501.85, 'wfuM2upHyT', 481.77, 0, 22, '2000-04-18 07:16:07', '2022-09-22 16:44:05');
INSERT INTO `products_sku` VALUES (28, 15, 'LUHVG8667076841', '冰膜', '{\"key7\": 80, \"key84\": 193, \"key87\": 72, \"key360\": 9, \"key541\": 585, \"key543\": 5}', 'LnroJ7BNVN', 149.00, 311.67, 'oIe7j4pLP1', 664.90, 1, 857, '2021-09-02 07:35:47', '2015-01-28 19:54:21');
INSERT INTO `products_sku` VALUES (29, 28, 'CWAJF5016483632', '卫生巾', '{\"key56\": 73, \"key274\": 62}', 'dQNCcMj5yx', 556.00, 795.61, 'hRbnpvZxBO', 767.47, 0, 828, '2020-07-02 01:12:16', '2007-08-10 09:29:16');
INSERT INTO `products_sku` VALUES (30, 17, 'RLLSL2562243042', '氨基酸泡泡慕斯', '{\"key7\": 229, \"key27\": 65}', '88gfrnrVn2', 498.00, 433.25, 'dLXGIZdpAU', 264.61, 0, 474, '2005-07-08 10:18:01', '2014-07-29 16:55:29');
INSERT INTO `products_sku` VALUES (31, 4, 'LCJCB5485840074', '玻尿酸', '{\"key6\": 4, \"key838\": 68, \"key977\": 74}', 'CvgDotAF0k', 487.00, 573.16, 'MzqeyZ6VvN', 411.63, 0, 757, '2022-06-26 20:34:54', '2009-10-24 16:38:55');
INSERT INTO `products_sku` VALUES (32, 7, 'XDIPH5502138368', '内衣洗衣液', '{\"key4\": 77, \"key15\": 9, \"key98\": 765}', 'g6WZhPshPS', 260.00, 245.93, 'GlNrqkZShe', 740.23, 0, 740, '2016-04-05 17:37:54', '2023-09-21 20:06:54');
INSERT INTO `products_sku` VALUES (33, 29, 'IBFAW6506411667', '去屑洗发水', '{\"key828\": 71}', 'crU1UzxFt2', 603.00, 137.44, 'SjGNGMNPoJ', 731.44, 0, 327, '2022-02-17 17:27:29', '2000-04-11 13:59:50');
INSERT INTO `products_sku` VALUES (34, 12, 'EGITP7518371785', '脱毛膏/6盒脱毛膏+3支芦荟胶', '{\"key916\": 8}', '5t97sbymk2', 322.00, 498.85, 'IvNgKzh4UN', 694.97, 1, 602, '2016-06-11 01:49:02', '2022-02-10 02:20:26');
INSERT INTO `products_sku` VALUES (35, 22, 'DVCJQ2471531488', '抗皱眼霜', '{\"key2\": 9, \"key70\": 2, \"key322\": 40, \"key915\": 342}', 'J9HvaSX3KJ', 276.00, 768.47, 'GHMSWxlAIX', 995.03, 1, 586, '2016-06-04 21:31:24', '2011-10-07 06:39:21');
INSERT INTO `products_sku` VALUES (36, 7, 'IXCFG1288542486', '24K金/精华', '{\"key2\": 6, \"key4\": 5, \"key8\": 7, \"key87\": 1}', 'IVG0YVEVXh', 892.00, 401.16, 'NcMh9hqi58', 159.59, 0, 572, '2001-05-17 01:03:18', '2008-03-26 04:05:22');
INSERT INTO `products_sku` VALUES (37, 17, 'ZQBUB1023158808', '气垫BB', '{\"key60\": 5}', 'GoEQYPpLus', 82.00, 846.19, '4toOgqrW1S', 583.06, 1, 878, '2015-03-28 14:33:20', '2000-10-22 01:17:55');
INSERT INTO `products_sku` VALUES (38, 28, 'IWLVH2067512051', '燕窝面膜', '{\"key16\": 323}', 'DkYtzQlhTX', 655.00, 690.96, 'f7cx7XVpm5', 903.96, 1, 451, '2000-10-07 06:00:43', '2023-02-12 10:02:44');
INSERT INTO `products_sku` VALUES (39, 23, 'BLCSH2158566844', '抗皱眼霜', '{\"key581\": 923}', 'TuMNqp4N4e', 584.00, 99.21, 'xY6Rn6jFRX', 773.60, 1, 97, '2006-12-15 17:45:23', '2014-08-14 12:20:26');
INSERT INTO `products_sku` VALUES (40, 10, 'TVTVM3324034852', '24K金/精华', '{\"key17\": 57, \"key34\": 35, \"key55\": 79, \"key99\": 652, \"key556\": 53, \"key787\": 50}', '63FnCCWRzp', 611.00, 916.77, 'oyyvtkbkbw', 498.90, 0, 820, '2018-11-13 04:29:11', '2023-05-01 17:31:33');
INSERT INTO `products_sku` VALUES (41, 5, 'YXWJO7644111040', '冰膜', '{\"key6\": 5, \"key89\": 9}', 'u82ffDNn6M', 411.00, 677.52, 'arQWVUN8Ml', 855.80, 0, 111, '2014-01-03 19:51:27', '2012-01-13 03:26:15');
INSERT INTO `products_sku` VALUES (42, 25, 'SIQQO0427180148', '洗衣液', '{\"key7\": 47, \"key9\": 6, \"key97\": 74, \"key888\": 2, \"key965\": 5}', '8GUcKQpXzy', 279.00, 115.92, 'Uaj6Dp03Lj', 426.96, 1, 56, '2016-03-10 20:32:50', '2020-02-09 20:10:17');
INSERT INTO `products_sku` VALUES (43, 21, 'UNZDR7354466538', '24K金/精华', '{\"key6\": 7, \"key93\": 5, \"key357\": 6, \"key857\": 232, \"key888\": 94}', '1DHr2K6iiF', 918.00, 42.10, 'mH17UmJHQX', 747.80, 1, 620, '2013-11-05 16:56:28', '2004-11-23 18:38:47');
INSERT INTO `products_sku` VALUES (44, 11, 'OYIBL0560130013', '抗皱乳', '{\"key5\": 139, \"key8\": 2, \"key9\": 1, \"key66\": 23, \"key353\": 751}', 'Ntci8mofN0', 483.00, 937.60, '6hz0r6Hugq', 177.62, 1, 741, '2023-07-09 16:34:06', '2007-08-26 11:59:21');
INSERT INTO `products_sku` VALUES (45, 22, 'FGXLQ4143245415', '脱毛膏/6盒脱毛膏+3支芦荟胶', '{\"key1\": 7, \"key5\": 522, \"key7\": 80, \"key8\": 579, \"key33\": 5, \"key460\": 6}', 'zP1IxBRzwn', 423.00, 955.91, 'VDSAENZzBz', 521.77, 0, 115, '2019-10-24 14:18:27', '2006-02-21 00:54:58');
INSERT INTO `products_sku` VALUES (46, 28, 'TFMLC2788001231', '燕窝面膜', '{\"key2\": 5}', 'awzVV40QNp', 129.00, 981.90, 'sL27H8e1bS', 260.53, 0, 769, '2021-08-07 22:27:19', '2024-05-22 06:04:17');
INSERT INTO `products_sku` VALUES (47, 20, 'ABIPB0541864345', '烟酰胺面膜', '{\"key15\": 979, \"key22\": 3, \"key76\": 56, \"key759\": 491}', '0bVzLSRkXl', 580.00, 745.68, 'DAgn7zxtaP', 932.72, 0, 563, '2001-03-23 18:02:09', '2009-06-26 08:01:02');
INSERT INTO `products_sku` VALUES (48, 28, 'AXMBS4278346353', '内衣洗衣液', '{\"key36\": 920}', 'sMAUlDtzKO', 909.00, 825.25, 'bcn8V98bxm', 796.18, 0, 831, '2003-03-31 16:03:09', '2024-09-18 08:42:42');
INSERT INTO `products_sku` VALUES (49, 11, 'ZSKFO7731346782', '燕窝面膜', '{\"key4\": 76, \"key769\": 3, \"key831\": 81}', 'RwES7FyTQl', 205.00, 181.68, 'B1Y6whSmeR', 971.18, 1, 818, '2002-11-25 11:17:38', '2009-12-08 22:18:21');
INSERT INTO `products_sku` VALUES (50, 2, 'LEQLJ7214367478', '卫生巾', '{\"key2\": 56, \"key14\": 60, \"key31\": 54, \"key93\": 768, \"key167\": 7, \"key859\": 1}', 'teWCQhLTEJ', 959.00, 829.01, '7e39zwg02H', 712.42, 0, 111, '2000-01-21 22:25:29', '2023-05-28 02:01:16');
INSERT INTO `products_sku` VALUES (51, 13, 'AORIE4728203022', '内衣洗衣液', '{\"key5\": 95, \"key7\": 1, \"key184\": 51}', 'NYVM4jCJvt', 535.00, 195.52, 'QRynZYdep2', 668.37, 1, 328, '2003-06-05 00:30:34', '2016-10-23 09:46:33');
INSERT INTO `products_sku` VALUES (52, 5, 'UTPUP0048463660', '香氛洗发水', '{\"key2\": 15, \"key84\": 12, \"key439\": 66, \"key834\": 28}', 'bbc5Y2mnUX', 633.00, 490.96, 'UPmYC11Bha', 364.39, 1, 269, '2005-05-13 03:05:22', '2011-09-21 23:01:06');
INSERT INTO `products_sku` VALUES (53, 13, 'LQCAG2555711838', '冰膜', '{\"key2\": 4, \"key36\": 3, \"key69\": 14, \"key279\": 49}', 'y8ozXS9pir', 561.00, 288.92, 'DmNC8WNLIj', 478.30, 1, 303, '2006-12-10 17:08:54', '2001-09-25 19:35:15');
INSERT INTO `products_sku` VALUES (54, 24, 'YGLCF0630554182', '冰膜', '{\"key2\": 98, \"key9\": 904, \"key91\": 7, \"key595\": 6, \"key814\": 2}', 'vWvP1F1U0Q', 538.00, 679.02, '39UxfYcbug', 14.73, 1, 849, '2019-06-11 23:01:40', '2024-02-07 20:24:23');
INSERT INTO `products_sku` VALUES (55, 11, 'JHNDO4381420066', '柔顺护发膜', '{\"key4\": 17, \"key5\": 23, \"key59\": 547, \"key426\": 3, \"key440\": 378}', 'cW78Y2AWXA', 522.00, 30.90, '0Vqj8h3Lbu', 252.71, 0, 87, '2024-08-23 16:39:35', '2021-08-07 17:11:52');
INSERT INTO `products_sku` VALUES (56, 25, 'ZDOHR1050734771', '牙膏', '{\"key2\": 11, \"key8\": 946, \"key338\": 286, \"key796\": 6}', 'MLFQEZfzhG', 838.00, 86.32, '9rYKMLIcHM', 139.90, 0, 55, '2001-12-07 07:14:40', '2016-07-19 02:44:00');
INSERT INTO `products_sku` VALUES (57, 25, 'GDZBB3464822106', '24K金/乳', '{\"key2\": 41, \"key570\": 85}', 'nWYgmPY88X', 533.00, 275.78, 'fyLDeKaUvx', 469.16, 1, 914, '2014-05-19 11:35:50', '2007-12-12 05:44:53');
INSERT INTO `products_sku` VALUES (58, 29, 'FEWLE2534053781', '24K金/乳', '{\"key3\": 500, \"key4\": 28, \"key5\": 327, \"key9\": 624, \"key55\": 1}', 'sWhn0VU6C9', 888.00, 393.58, 'CSfWHTrsa9', 94.43, 0, 679, '2025-04-12 04:49:20', '2010-04-23 13:11:58');
INSERT INTO `products_sku` VALUES (59, 22, 'YNMVY5884181054', '气垫BB', '{\"key6\": 34, \"key60\": 209, \"key512\": 471}', 'ZAJrz7xv0i', 882.00, 757.35, 'SSiP5bAXqt', 330.31, 1, 239, '2018-06-28 17:31:09', '2021-08-21 12:06:20');
INSERT INTO `products_sku` VALUES (60, 10, 'CFKMJ1767824225', '抗皱精华', '{\"key28\": 64, \"key34\": 2, \"key53\": 3, \"key358\": 665, \"key604\": 699, \"key860\": 1}', '32kt2UXM6t', 861.00, 573.13, 'OIOzikx3gC', 321.31, 1, 798, '2003-12-21 15:38:04', '2017-04-24 02:15:56');
INSERT INTO `products_sku` VALUES (61, 6, 'LGUMK3568858617', '蜜都舒缓修护柔肤套', '{\"key8\": 116, \"key58\": 61, \"key680\": 6}', 'VSmr7bnmGy', 274.00, 373.28, 'oCDGvuQY6t', 17.36, 0, 273, '2012-02-26 16:41:09', '2008-12-03 11:51:34');
INSERT INTO `products_sku` VALUES (62, 19, 'VLQOX5585785241', '新冰膜+3支喷雾', '{\"key5\": 591, \"key30\": 5, \"key135\": 1}', '66FTHz1aah', 177.00, 548.32, 'Koi6manBPx', 698.40, 0, 706, '2006-11-18 17:26:15', '2013-08-17 19:51:29');
INSERT INTO `products_sku` VALUES (63, 19, 'WFLCF7285624001', '蜜都舒缓修护柔肤套', '{\"key2\": 187}', 'PPI4OSNAHh', 503.00, 915.71, 'iYlDEgV9Il', 612.91, 1, 815, '2016-05-01 00:46:36', '2024-10-21 15:35:04');
INSERT INTO `products_sku` VALUES (64, 4, 'ERARZ6765403187', '烟酰胺面膜', '{\"key6\": 617, \"key9\": 831}', 'XQiSFmipkq', 695.00, 280.37, 'mUFBZlZeDX', 331.76, 0, 39, '2011-04-30 06:18:35', '2011-08-31 07:50:06');
INSERT INTO `products_sku` VALUES (65, 4, 'IRTCP0343748168', '冰膜', '{\"key3\": 94, \"key421\": 798, \"key634\": 473, \"key717\": 731, \"key955\": 191, \"key990\": 7}', 'uvmPj06lsY', 459.00, 683.53, 'FOiFpp92pn', 147.91, 1, 64, '2007-10-18 20:19:05', '2014-06-01 15:29:22');
INSERT INTO `products_sku` VALUES (66, 28, 'OHZIO4272540642', '邂逅时光嫩肤身体乳', '{\"key2\": 91, \"key15\": 4, \"key84\": 69, \"key115\": 395, \"key367\": 9, \"key704\": 1}', 'Am06PqqniI', 668.00, 677.88, 'V0Bply27JP', 447.52, 1, 126, '2021-11-21 02:59:01', '2015-01-21 01:15:56');
INSERT INTO `products_sku` VALUES (67, 16, 'NKFWW5523205264', '氨基酸泡泡慕斯', '{\"key539\": 85}', 'I7Psh0L8Ct', 450.00, 419.39, 'Tu4F7DujMd', 692.22, 1, 41, '2020-07-28 21:18:54', '2012-02-07 23:50:21');
INSERT INTO `products_sku` VALUES (68, 24, 'ARZCI5283575030', '冰膜', '{\"key171\": 33}', 'kqPAE4RwdC', 984.00, 566.97, 'EzymrHofqD', 421.09, 0, 559, '2006-03-05 04:49:48', '2016-10-16 22:03:42');
INSERT INTO `products_sku` VALUES (69, 31, 'BJOMB1607801130', '氨基酸泡泡慕斯', '{\"key4\": 339, \"key14\": 2, \"key37\": 72, \"key529\": 29}', '7WRMxFdIwn', 130.00, 339.87, 'fcsiP3546g', 231.31, 1, 408, '2024-01-20 23:57:54', '2023-09-02 16:00:11');
INSERT INTO `products_sku` VALUES (70, 19, 'MSHIB3400732673', '抗皱精华', '{\"key1\": 402, \"key377\": 448}', 'Xifpkc2BjU', 241.00, 633.09, 'HuipIXdbXc', 576.21, 1, 441, '2008-10-25 01:46:25', '2015-07-22 11:26:17');
INSERT INTO `products_sku` VALUES (71, 8, 'FFSSW3607522001', '抗皱霜', '{\"key1\": 70, \"key86\": 5, \"key117\": 51, \"key932\": 1}', 'znQ3HhgbCa', 231.00, 513.26, 'Hv11K5K8lD', 575.82, 1, 209, '2001-12-20 16:16:11', '2015-11-19 19:56:30');
INSERT INTO `products_sku` VALUES (72, 2, 'YHMDF4504221116', '赠送小安瓶', '{\"key7\": 9, \"key8\": 4, \"key21\": 899, \"key37\": 4, \"key341\": 4, \"key800\": 6}', 'X5EgAceiYZ', 321.00, 434.21, '2aB8GVYYTS', 342.24, 0, 31, '2013-11-19 02:44:50', '2013-03-12 19:11:45');
INSERT INTO `products_sku` VALUES (73, 1, 'UCTZL2828040772', '去屑洗发水', '{\"key2\": 1, \"key82\": 746, \"key478\": 9, \"key815\": 54}', '6UAtLtl1bS', 720.00, 424.35, 'oh7R0tsdHB', 9.29, 1, 953, '2008-05-19 12:36:16', '2022-05-30 20:02:48');
INSERT INTO `products_sku` VALUES (74, 25, 'BTZYQ7334206324', '玻尿酸', '{\"key934\": 26}', '0nO2En0GZj', 280.00, 922.62, 'Rwcpif3JD4', 541.78, 1, 773, '2005-03-17 12:44:28', '2016-10-08 00:08:11');
INSERT INTO `products_sku` VALUES (75, 9, 'TTOKH2670475868', '洗衣液', '{\"key1\": 6, \"key2\": 75, \"key6\": 303, \"key544\": 4}', '7ZsxPpjCdA', 304.00, 507.01, 'AL4YFG3jMZ', 346.87, 0, 330, '2010-12-11 18:13:33', '2001-02-19 21:07:09');
INSERT INTO `products_sku` VALUES (76, 31, 'ZUBZC7043225343', '卫生巾', '{\"key8\": 2, \"key76\": 37, \"key494\": 5}', 'BqHHTzeWr2', 379.00, 865.38, 'F5GSSwVtqK', 128.39, 1, 8, '2000-11-09 12:16:38', '2015-02-21 08:13:39');
INSERT INTO `products_sku` VALUES (77, 22, 'QYPND7452737802', '内衣洗衣液', '{\"key1\": 7, \"key2\": 3, \"key4\": 98, \"key7\": 7, \"key210\": 5}', 'vHxhwQHEqY', 663.00, 154.27, 'GzGjiXXTkN', 578.65, 1, 851, '2006-02-02 12:06:15', '2002-04-15 21:52:21');
INSERT INTO `products_sku` VALUES (78, 22, 'FITVF8251848602', '赠送小安瓶', '{\"key5\": 78, \"key606\": 810}', 'G8hDKEKDvh', 703.00, 424.16, 'MwLWdjXj9z', 520.64, 0, 369, '2006-08-07 20:36:53', '2012-12-02 01:07:52');
INSERT INTO `products_sku` VALUES (79, 19, 'MHXSH3038517264', '蜜都安睡裤', '{\"key4\": 17, \"key47\": 504}', '62sMq9DjtD', 196.00, 705.67, 'BTXIME3QFy', 480.32, 0, 622, '2002-08-21 07:36:44', '2022-09-30 18:05:35');
INSERT INTO `products_sku` VALUES (80, 21, 'UDPGP6072571236', '去屑洗发水', '{\"key6\": 706, \"key12\": 243, \"key78\": 4}', 'NhNDhECHeY', 708.00, 904.91, 'sdORe7gSwF', 592.51, 0, 436, '2001-03-07 15:05:39', '2008-07-28 21:13:36');
INSERT INTO `products_sku` VALUES (81, 21, 'MFCDQ0244515706', '油污净', '{\"key27\": 70}', 'yZq3p7RkfT', 256.00, 929.32, 'PbmSrqZaqI', 350.04, 1, 58, '2003-06-30 06:43:48', '2021-06-28 09:07:41');
INSERT INTO `products_sku` VALUES (82, 27, 'WSBIK1603615005', '24K金/精华', '{\"key24\": 4, \"key53\": 4, \"key89\": 20, \"key726\": 966}', 'krtYaQKXnt', 154.00, 395.57, 'SPakzqJvkk', 503.86, 0, 812, '2010-01-29 06:03:25', '2005-02-03 12:53:10');
INSERT INTO `products_sku` VALUES (83, 25, 'IWZJV4640727553', '氨基酸泡泡慕斯', '{\"key9\": 8, \"key22\": 22, \"key682\": 170}', 'hzIrplZ9IQ', 176.00, 852.57, 'xF2lZkrfo3', 472.73, 0, 90, '2001-09-01 13:56:47', '2004-04-28 02:07:49');
INSERT INTO `products_sku` VALUES (84, 28, 'LBUUP8837145851', '抗皱乳', '{\"key2\": 4, \"key5\": 81}', 'tlK1B9dCID', 568.00, 307.91, '5gHip4D2C2', 948.26, 1, 875, '2020-03-07 20:07:59', '2015-04-12 19:19:18');
INSERT INTO `products_sku` VALUES (85, 25, 'CEKCH4611835658', '抗皱水', '{\"key44\": 752}', 'ltMkFxg91d', 533.00, 233.39, '0NgnqGpWHj', 330.13, 1, 242, '2015-01-09 16:50:34', '2022-05-05 14:51:15');
INSERT INTO `products_sku` VALUES (86, 13, 'MVAPB4723262111', '油污净', '{\"key7\": 71, \"key68\": 437, \"key231\": 18, \"key289\": 841, \"key323\": 1}', 'v1LeUrV6jH', 522.00, 869.58, 'CM5YNbazBi', 635.59, 0, 8, '2025-02-10 08:51:47', '2024-03-18 11:21:24');
INSERT INTO `products_sku` VALUES (87, 24, 'SWPOP4367273603', '香氛洗发水', '{\"key59\": 124, \"key66\": 9}', 'hqi195bkkI', 430.00, 690.29, 'phCIHfrkI8', 68.06, 1, 226, '2001-05-21 19:17:29', '2020-02-13 15:54:55');
INSERT INTO `products_sku` VALUES (88, 7, 'VYOBF3277560812', '防晒喷雾/5瓶', '{\"key8\": 339, \"key20\": 8, \"key488\": 542, \"key509\": 71}', 'jNNxPPpCJG', 113.00, 591.74, 'pS8gIw9K2W', 732.35, 0, 956, '2017-11-07 08:57:00', '2010-11-27 15:24:19');
INSERT INTO `products_sku` VALUES (89, 31, 'VZFWY7371130438', '牙膏', '{\"key96\": 94, \"key97\": 88, \"key104\": 33, \"key691\": 2, \"key737\": 5, \"key807\": 7}', 'q0kul4yhD4', 697.00, 443.10, 'uvP3sfB4l6', 688.05, 0, 765, '2022-10-06 07:01:54', '2013-05-05 15:54:25');
INSERT INTO `products_sku` VALUES (90, 15, 'KUOLB5144267041', '洗衣液', '{\"key2\": 44}', 'KYtPINSQnW', 775.00, 656.55, 'nVfeI0Y2r8', 217.52, 1, 365, '2012-05-01 11:13:37', '2013-03-04 20:44:32');
INSERT INTO `products_sku` VALUES (91, 28, 'GJCXN4538770058', '牙膏', '{\"key8\": 99, \"key409\": 469, \"key929\": 8}', 'd8DOJr6ex6', 451.00, 444.08, 'cvHBhDQMQ8', 168.86, 0, 786, '2009-02-27 00:31:13', '2002-11-13 03:04:24');
INSERT INTO `products_sku` VALUES (92, 20, 'YGFRZ2288645234', '蜜都安睡裤', '{\"key3\": 31, \"key46\": 47, \"key77\": 341, \"key96\": 153}', 'JUYQhW5kl1', 598.00, 595.37, 'PJLxAoGDZk', 489.61, 0, 408, '2003-04-04 03:17:33', '2025-06-01 22:30:22');
INSERT INTO `products_sku` VALUES (93, 31, 'XVFRO5412704584', '生姜洗发水', '{\"key8\": 91, \"key601\": 82}', '7Alc6piXiY', 429.00, 112.53, 'SXCqAy3Lxr', 334.46, 1, 369, '2003-05-25 23:27:30', '2017-07-06 22:21:20');
INSERT INTO `products_sku` VALUES (94, 26, 'YMWNT3422402318', '冰膜', '{\"key1\": 8, \"key2\": 175, \"key6\": 1, \"key26\": 209, \"key496\": 87, \"key887\": 944}', '4T2Eq0rPsZ', 275.00, 408.61, 'EPNFAFtsew', 797.58, 1, 845, '2017-10-08 13:49:59', '2004-03-06 09:10:07');
INSERT INTO `products_sku` VALUES (95, 14, 'CBMLE7262622164', '生姜洗发水', '{\"key5\": 52, \"key22\": 8, \"key174\": 38}', 'bU9qi9so4k', 203.00, 442.17, 'HV0mXmm7jv', 901.55, 1, 618, '2015-03-14 09:44:20', '2007-01-24 07:38:52');
INSERT INTO `products_sku` VALUES (96, 3, 'PTSME6883347833', '抗皱面膜', '{\"key73\": 711, \"key92\": 22, \"key888\": 266}', '0s8lqhR4GM', 86.00, 892.32, 'SZ9D5Btojm', 409.23, 0, 904, '2008-02-22 16:21:06', '2010-03-09 14:07:19');
INSERT INTO `products_sku` VALUES (97, 25, 'HEJRN1503115662', '卫生巾', '{\"key8\": 14, \"key17\": 8, \"key36\": 156, \"key50\": 669}', 'fBNCjYZes2', 51.00, 654.75, 'GoWXbvH8r1', 319.85, 0, 408, '2020-09-28 19:24:25', '2019-04-06 14:59:56');
INSERT INTO `products_sku` VALUES (99, 24, 'AYTLQ2081506803', '凝时抗皱焕肤套盒', '{\"key9\": 7, \"key930\": 112}', 'zctUn1Q2Q8', 100.00, 162.86, 'bRfKyuCdZI', 655.75, 1, 19, '2012-11-12 15:11:24', '2005-05-03 21:42:09');
INSERT INTO `products_sku` VALUES (100, 3, 'DZDDN7557624470', '气垫BB', '{\"key15\": 6, \"key303\": 9, \"key419\": 410, \"key725\": 247, \"key901\": 64}', 'SQ1YNEtbGh', 18.00, 358.89, '2FyiF4d83L', 417.95, 0, 589, '2025-06-12 07:56:13', '2022-03-09 21:11:32');

-- ----------------------------
-- Table structure for products_spu
-- ----------------------------
DROP TABLE IF EXISTS `products_spu`;
CREATE TABLE `products_spu`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品编码',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `brand_id` bigint NULL DEFAULT NULL COMMENT '品牌ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '分类ID（指向二级分类）',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '计量单位',
  `special_rule` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '特殊计量规则，如3件扣1',
  `quota_deduct_ratio` decimal(18, 2) NULL DEFAULT 1.00 COMMENT '库存额度扣除比例',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：1-启用，0-禁用',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '商品描述',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `idx_products_spu_code`(`code` ASC) USING BTREE,
  INDEX `idx_products_spu_brand`(`brand_id` ASC) USING BTREE,
  INDEX `idx_products_spu_category`(`category_id` ASC) USING BTREE,
  CONSTRAINT `fk_products_spu_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_products_spu_category` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品SPU表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of products_spu
-- ----------------------------
INSERT INTO `products_spu` VALUES (1, 'CYQ6610785714', '洗洁精', 1009, 12, 'P92yCPcaMe', 'sf8zbboXkZ', 420.00, 0, '这是一个商品描述', 288, '2010-03-18 12:27:02', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (2, 'FTE1214517677', '牙膏', 1009, 1, 'wUZ1cJmBYu', 't4pSvhdQpG', 256.00, 0, '这是一个商品描述', 428, '2003-10-24 03:23:08', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (3, 'JQT9687371576', '防晒霜', 1010, 15, 'SRCnpg0wdY', 'VuBxupsYkW', 437.00, 1, '这是一个商品描述', 338, '2019-07-03 20:53:51', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (4, 'QXY9383010677', '小安瓶', 1003, 13, 'jORtmj6qE4', 'rneMlT2xZy', 640.00, 1, '这是一个商品描述', 335, '2008-04-14 04:17:00', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (5, 'PLG3845090655', '牙膏', 1006, 4, 'BtHEfwZPiR', '3LIXc5uU94', 442.00, 0, '这是一个商品描述', 454, '2009-09-16 07:36:10', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (6, 'ECH3730865845', '精华', 1002, 7, 'oMOgdfvi8x', 'UCizOo0LKS', 682.00, 0, '这是一个商品描述', 456, '2021-08-29 19:51:45', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (7, 'BJW3668663426', '凝时抗皱焕肤套盒', 1002, 17, 'mISjHNK6Ul', 'j7XYYj2jaG', 29.00, 0, '这是一个商品描述', 836, '2002-11-19 08:51:29', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (8, 'TZH0829332340', '保湿抗皱喷雾', 1008, 1, 'eXydqy4WVH', 'Z5zDVnHbrL', 129.00, 0, '这是一个商品描述', 13, '2001-12-28 14:58:22', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (9, 'NMH1061679346', '蜜都舒缓修护柔肤套', 1005, 9, 'RjjdFdq57t', 'IyAHbKVIaG', 583.00, 1, '这是一个商品描述', 307, '2007-11-03 04:14:34', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (10, 'EBN6281198919', '补水喷雾', 1003, 5, 'NiqnQZlgm1', 'HmFTKHGRzf', 121.00, 0, '这是一个商品描述', 230, '2005-05-30 20:58:13', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (11, 'JZX2737265514', '牙膏', 1009, 7, 't2I8wjafl8', '1ctIv9qlkA', 539.00, 0, '这是一个商品描述', 29, '2002-12-06 13:36:44', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (12, 'XFU0669350398', '凝时抗皱焕肤套盒', 1008, 18, 'AlnnqI8O8O', 'mDs79R3fAA', 124.00, 1, '这是一个商品描述', 574, '2014-04-15 05:50:53', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (13, 'GIZ9488745222', '防晒霜', 1006, 13, 'Cpcflq6B4L', 'UVvujJfVTh', 687.00, 1, '这是一个商品描述', 821, '2002-06-10 04:44:10', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (14, 'PDO6231081702', '护垫', 1002, 14, 'axHnjVn7BV', 'yTAC33a2lm', 155.00, 1, '这是一个商品描述', 102, '2008-03-08 21:18:32', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (15, 'HXC1214608978', '油污净', 1010, 14, '7cAnY92uzD', 'FejduvzYC5', 541.00, 1, '这是一个商品描述', 108, '2011-01-13 08:28:01', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (16, 'TJM3818092671', '洗洁精', 1009, 10, 'mkkdmaa1Lb', 'Z4dulD5Xbm', 529.00, 1, '这是一个商品描述', 605, '2002-07-31 07:14:26', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (17, 'RBQ7303185405', '洗发水', 1005, 7, 'gNsVN08lAR', 'zjnFUhhyPM', 862.00, 1, '这是一个商品描述', 683, '2013-08-15 14:35:44', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (18, 'RWT3676217359', '面膜', 1011, 6, 'RTWlxR1fYQ', 'f3lXQihtmw', 667.00, 0, '这是一个商品描述', 886, '2016-01-11 18:28:12', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (19, 'QXO2333013817', '水', 1010, 9, 'KF08OOWNwo', 'LyRWdX1PTm', 10.00, 1, '这是一个商品描述', 519, '2000-09-26 13:49:32', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (20, 'EGX5865329055', '乳', 1006, 4, 'wU7gTK1pG9', 'mJV6EMeXt9', 854.00, 1, '这是一个商品描述', 384, '2014-03-08 22:43:06', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (21, 'BIE5841642487', '精华', 1003, 5, 'UWz3ejfOfM', 'VEtsGDcp3r', 900.00, 1, '这是一个商品描述', 847, '2004-08-15 15:59:41', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (22, 'JND2003181438', '卫生巾', 1004, 1, 'DcTxFa6z80', 'bPKbKQGAr3', 251.00, 1, '这是一个商品描述', 718, '2008-09-06 23:10:02', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (23, 'UWT7192100513', '抗皱眼霜', 1007, 17, 'qzZReR1pYC', 'XBqD48aDWM', 752.00, 1, '这是一个商品描述', 460, '2004-06-13 11:37:07', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (24, 'VVN3516263088', '水', 1008, 1, 'V8zCkk09qm', '6p3N6A4rTI', 457.00, 1, '这是一个商品描述', 540, '2014-05-09 05:14:37', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (25, 'VAS6512984339', '玻尿酸', 1005, 2, 'WXFWAhcjT9', 'JTtrx4SAel', 102.00, 1, '这是一个商品描述', 10, '2016-07-02 14:25:45', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (26, 'PDW8181290411', '乳', 1003, 8, 'oUIyQhCmU9', 'vaXW1r7OHN', 97.00, 1, '这是一个商品描述', 805, '2014-04-15 07:48:07', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (27, 'PTF7651621215', '贵妇膏', 1003, 12, 'INBYkxlOU5', 'IaApwHRwEB', 663.00, 1, '这是一个商品描述', 147, '2009-05-14 02:59:17', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (28, 'UTX4998186799', '抗皱眼霜', 1008, 1, 'XETzwVNXaU', 'gJ9Ms7iFn6', 619.00, 1, '这是一个商品描述', 826, '2016-12-22 08:24:54', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (29, 'KGI8188863842', '油污净', 1005, 1, 'xISYSgdvvc', 'EocSzldTDp', 839.00, 1, '这是一个商品描述', 604, '2004-09-12 22:42:58', '2025-06-17 15:16:29');
INSERT INTO `products_spu` VALUES (31, 'ARS5865720086', '牙膏', 1002, 8, 'z8uOgy4MmK', '5kzQhyhB4x', 576.00, 1, '这是一个商品描述', 361, '2019-02-12 00:30:57', '2025-06-17 15:16:29');

-- ----------------------------
-- Table structure for role_permissions
-- ----------------------------
DROP TABLE IF EXISTS `role_permissions`;
CREATE TABLE `role_permissions`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  PRIMARY KEY (`role_id`, `permission_id`) USING BTREE,
  INDEX `permission_id`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of role_permissions
-- ----------------------------
INSERT INTO `role_permissions` VALUES (14, 1);
INSERT INTO `role_permissions` VALUES (18, 1);
INSERT INTO `role_permissions` VALUES (21, 2);
INSERT INTO `role_permissions` VALUES (26, 2);
INSERT INTO `role_permissions` VALUES (15, 3);
INSERT INTO `role_permissions` VALUES (22, 3);
INSERT INTO `role_permissions` VALUES (7, 4);
INSERT INTO `role_permissions` VALUES (13, 4);
INSERT INTO `role_permissions` VALUES (18, 4);
INSERT INTO `role_permissions` VALUES (28, 4);

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of roles
-- ----------------------------
INSERT INTO `roles` VALUES (1, '图书馆管理员', '外销部');
INSERT INTO `roles` VALUES (2, '零售助理', '会计及金融部');
INSERT INTO `roles` VALUES (3, '客户服务经理', '法律部');
INSERT INTO `roles` VALUES (4, '社交媒体协调员', '生产部');
INSERT INTO `roles` VALUES (5, '精算师', '销售部');
INSERT INTO `roles` VALUES (6, '运营经理', '采购部');
INSERT INTO `roles` VALUES (7, '人力资源经理', '市场部');
INSERT INTO `roles` VALUES (8, '运营经理', '工程部');
INSERT INTO `roles` VALUES (9, '演员', '人力资源部');
INSERT INTO `roles` VALUES (10, '园艺家', '采购部');
INSERT INTO `roles` VALUES (11, '兽医助理', '产品质量部');
INSERT INTO `roles` VALUES (12, '牙齿矫正医生', '生产部');
INSERT INTO `roles` VALUES (13, '作家', '信息技术支持部');
INSERT INTO `roles` VALUES (14, '演员', '公关部');
INSERT INTO `roles` VALUES (15, '社交媒体协调员', '行政管理部');
INSERT INTO `roles` VALUES (16, '信息安全分析师', '研究及开发部');
INSERT INTO `roles` VALUES (17, '生物化学家', '会计及金融部');
INSERT INTO `roles` VALUES (18, '工程师', '生产部');
INSERT INTO `roles` VALUES (19, '美容师', '工程部');
INSERT INTO `roles` VALUES (20, 'UX / UI设计员', '采购部');
INSERT INTO `roles` VALUES (21, '移动应用程式开发人员', '市场部');
INSERT INTO `roles` VALUES (22, '客户服务经理', '外销部');
INSERT INTO `roles` VALUES (23, '水疗经理', '法律部');
INSERT INTO `roles` VALUES (24, 'UX / UI设计员', '研究及开发部');
INSERT INTO `roles` VALUES (25, '零售助理', '人力资源部');
INSERT INTO `roles` VALUES (26, '兽医助理', '销售部');
INSERT INTO `roles` VALUES (27, '专案经理', '生产部');
INSERT INTO `roles` VALUES (28, '纹身艺术家', '法律部');
INSERT INTO `roles` VALUES (29, '网页开发人员', '信息技术支持部');
INSERT INTO `roles` VALUES (30, '兽医', '产品质量部');

-- ----------------------------
-- Table structure for shipment_items
-- ----------------------------
DROP TABLE IF EXISTS `shipment_items`;
CREATE TABLE `shipment_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `shipment_id` bigint NOT NULL COMMENT '发货单ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `order_item_id` bigint NOT NULL COMMENT '订单明细ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` decimal(18, 2) NOT NULL COMMENT '本次发货数量',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `shipment_id`(`shipment_id` ASC) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE,
  INDEX `order_item_id`(`order_item_id` ASC) USING BTREE,
  INDEX `product_id`(`product_id` ASC) USING BTREE,
  CONSTRAINT `shipment_items_ibfk_4` FOREIGN KEY (`product_id`) REFERENCES `products_spu` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of shipment_items
-- ----------------------------

-- ----------------------------
-- Table structure for shipments
-- ----------------------------
DROP TABLE IF EXISTS `shipments`;
CREATE TABLE `shipments`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '发货单ID',
  `shipment_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发货单编号',
  `factory_id` bigint NULL DEFAULT NULL COMMENT '工厂ID',
  `shipment_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发货类型：工厂代发/经销商自提',
  `car_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '车牌号',
  `driver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '司机电话',
  `logistics_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物流单号',
  `logistics_company` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物流公司',
  `shipped_at` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `shipment_no`(`shipment_no` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of shipments
-- ----------------------------

-- ----------------------------
-- Table structure for system_logs
-- ----------------------------
DROP TABLE IF EXISTS `system_logs`;
CREATE TABLE `system_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户ID',
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作类型',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作IP',
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '操作详情',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `system_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_logs
-- ----------------------------

-- ----------------------------
-- Table structure for user_roles
-- ----------------------------
DROP TABLE IF EXISTS `user_roles`;
CREATE TABLE `user_roles`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE,
  INDEX `role_id`(`role_id` ASC) USING BTREE,
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_roles
-- ----------------------------
INSERT INTO `user_roles` VALUES (4, 1);
INSERT INTO `user_roles` VALUES (7, 3);
INSERT INTO `user_roles` VALUES (6, 4);
INSERT INTO `user_roles` VALUES (9, 4);
INSERT INTO `user_roles` VALUES (1, 5);
INSERT INTO `user_roles` VALUES (5, 5);
INSERT INTO `user_roles` VALUES (1, 6);
INSERT INTO `user_roles` VALUES (9, 12);
INSERT INTO `user_roles` VALUES (7, 20);
INSERT INTO `user_roles` VALUES (1, 23);
INSERT INTO `user_roles` VALUES (4, 26);
INSERT INTO `user_roles` VALUES (8, 28);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户头像',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码哈希',
  `status` tinyint NULL DEFAULT 1 COMMENT '1启用 0禁用',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `password_error_count` int NULL DEFAULT 0 COMMENT '密码错误次数',
  `lock_time` datetime NULL DEFAULT NULL COMMENT '锁定时间',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'ny1979', 'Nathan Young', 'https://api.dicebear.com/7.x/avataaars/svg', 'fBVbxnUeH8', 1, '2004-12-23 00:01:01', 'youngn', 63, '2010-03-09 21:52:45', 705, '2013-06-03 19:55:26', '2025-06-12 15:55:21');
INSERT INTO `users` VALUES (2, 'manuel7', 'Manuel Reyes', 'https://api.dicebear.com/7.x/avataaars/svg', 'Sl6mfNDv2k', 0, '2009-01-15 06:11:58', 'manur', 88, '2016-11-16 21:55:53', 307, '2021-01-11 08:45:26', '2025-06-12 15:55:25');
INSERT INTO `users` VALUES (3, 'ziyi10', 'Hao Ziyi', 'https://api.dicebear.com/7.x/avataaars/svg', 'wQo5HCg83L', 1, '2013-06-27 10:45:07', 'haziyi', 84, '2018-11-16 16:32:31', 622, '2005-04-30 04:59:37', '2025-06-12 15:55:28');
INSERT INTO `users` VALUES (4, 'rya', 'Yan Rui', 'https://api.dicebear.com/7.x/avataaars/svg', '8jRL1mZhhs', 0, '2011-11-01 10:33:41', 'yanrui', 60, '2004-02-29 19:12:39', 489, '2010-05-13 04:21:40', '2025-06-12 15:55:29');
INSERT INTO `users` VALUES (5, 'ruili', 'Li Rui', 'https://api.dicebear.com/7.x/avataaars/svg', 'FbWABpnWW3', 1, '2003-05-04 21:25:25', 'li1', 25, '2014-11-14 06:06:40', 238, '2020-01-09 11:45:27', '2025-06-12 15:55:30');
INSERT INTO `users` VALUES (6, 'xulan59', '徐岚', 'https://api.dicebear.com/7.x/avataaars/svg', '0ldSrcJcje', 1, '2006-05-12 00:38:51', 'xl9', 38, '2020-11-15 09:13:36', 628, '2005-06-15 16:21:17', '2025-06-12 15:55:30');
INSERT INTO `users` VALUES (7, 'wez', 'Wei Zitao', 'https://api.dicebear.com/7.x/avataaars/svg', '5vEC9vHgvt', 1, '2005-04-20 18:00:15', 'weizitao', 32, '2016-01-16 11:02:58', 846, '2002-08-20 14:41:20', '2025-06-12 15:55:31');
INSERT INTO `users` VALUES (8, 'admin', '毛晓明', 'https://api.dicebear.com/7.x/avataaars/svg', '123456', 1, '2015-03-09 06:36:58', 'xmao', 23, '2002-04-22 14:57:22', 229, '2021-07-23 19:08:53', '2025-06-12 15:55:31');
INSERT INTO `users` VALUES (9, 'denise1107', 'Denise Barnes', 'https://api.dicebear.com/7.x/avataaars/svg', 'bpi10cQ84o', 1, '2010-12-15 17:35:42', 'barnes10', 63, '2018-09-26 21:38:38', 742, '2016-11-12 05:22:16', '2025-06-12 15:55:34');
INSERT INTO `users` VALUES (10, 'petphyllis', 'Phyllis Peterson', 'https://api.dicebear.com/7.x/avataaars/svg', 'g8mvf7HzPT', 1, '2006-05-22 17:03:13', 'phyllispe', 68, '2016-08-13 05:31:14', 103, '2010-05-01 13:34:52', '2025-06-12 15:55:33');
INSERT INTO `users` VALUES (11, 'user1', 'user1', 'default-avatar.png', '123456', 1, NULL, NULL, 0, NULL, 0, '2025-06-14 15:44:05', '2025-06-14 17:28:05');
INSERT INTO `users` VALUES (13, 'user3', 'user1', 'default-avatar.png', '123456', 1, NULL, NULL, 0, NULL, 0, '2025-06-14 16:26:15', '2025-06-14 17:28:06');
INSERT INTO `users` VALUES (14, 'user13', 'user1', 'default-avatar.png', '123456', 1, NULL, NULL, 0, NULL, 0, '2025-06-14 17:23:01', '2025-06-14 17:28:07');
INSERT INTO `users` VALUES (15, 'user4', 'user4', 'default-avatar.png', '123456', 1, NULL, NULL, 0, NULL, 0, '2025-06-14 17:27:15', NULL);
INSERT INTO `users` VALUES (16, 'aaaaaa', 'bbbbbbbb', 'default-avatar.png', 'bbbbbbbbbbb', 0, NULL, NULL, 0, NULL, 0, '2025-06-16 14:56:12', '2025-06-17 13:02:35');

-- ----------------------------
-- Table structure for orders_history
-- ----------------------------
DROP TABLE IF EXISTS `orders_history`;
CREATE TABLE `orders_history`  (
  `Id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `OrderId` bigint NOT NULL COMMENT '订单ID',
  `OrderNo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单编号',
  `SenderName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '发件人姓名',
  `DealerId` bigint NOT NULL COMMENT '经销商ID',
  `FactoryId` bigint NULL DEFAULT NULL COMMENT '工厂ID',
  `Status` tinyint NOT NULL COMMENT '订单状态',
  `TotalAmount` decimal(18, 2) NOT NULL COMMENT '订单总金额',
  `Freight` decimal(18, 2) NOT NULL COMMENT '运费',
  `ReceiverName` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货人姓名',
  `ReceiverPhone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货人电话',
  `ReceiverAddress` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '收货地址',
  `Remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `CreatedBy` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `UpdatedBy` bigint NULL DEFAULT NULL COMMENT '修改人ID',
  `DeliveryType` tinyint NULL DEFAULT NULL COMMENT '快递类型',
  `CreatedAt` datetime NOT NULL COMMENT '创建时间',
  `UpdatedAt` datetime NOT NULL COMMENT '更新时间',
  `ImportId` bigint NULL DEFAULT NULL COMMENT '导入记录ID',
  `QuotaDeducted` decimal(18, 2) NOT NULL COMMENT '已扣除的库存额度',
  `QuotaReturned` decimal(18, 2) NOT NULL COMMENT '已归还的库存额度',
  `AuditBy` bigint NULL DEFAULT NULL COMMENT '审核人ID',
  `AuditAt` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `AuditRemark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核备注',
  `OrderDate` datetime NOT NULL COMMENT '订单日期',
  `ArchiveDate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '归档时间',
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `idx_order_id`(`OrderId` ASC) USING BTREE,
  INDEX `idx_order_no`(`OrderNo` ASC) USING BTREE,
  INDEX `idx_archive_date`(`ArchiveDate` ASC) USING BTREE
);
