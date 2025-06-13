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

 Date: 13/06/2025 18:57:06
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
) ENGINE = InnoDB AUTO_INCREMENT = 1011 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
  `quota` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '库存额度',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `match_id`(`match_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dealers
-- ----------------------------
INSERT INTO `dealers` VALUES (1, 'M123456', '张三', 12331.00);
INSERT INTO `dealers` VALUES (2, 'M714596', '史致远', 9343.94);
INSERT INTO `dealers` VALUES (3, 'M070978', '钱子异', 6137.29);
INSERT INTO `dealers` VALUES (4, 'M329883', '邱宇宁', 8758.85);
INSERT INTO `dealers` VALUES (5, 'M891822', '曾秀英', 6539.50);
INSERT INTO `dealers` VALUES (6, 'M053349', '何詩涵', 8926.22);
INSERT INTO `dealers` VALUES (7, 'M263476', '尹璐', 9012.20);
INSERT INTO `dealers` VALUES (8, 'M009774', '刘子韬', 5310.98);
INSERT INTO `dealers` VALUES (9, 'M696900', '马詩涵', 9271.61);
INSERT INTO `dealers` VALUES (10, 'M170712', '于致远', 7596.43);
INSERT INTO `dealers` VALUES (11, 'M934436', '陶致远', 8358.59);
INSERT INTO `dealers` VALUES (12, 'M592147', '唐璐', 9901.10);
INSERT INTO `dealers` VALUES (13, 'M943108', '林震南', 6953.48);
INSERT INTO `dealers` VALUES (14, 'M040689', '秦云熙', 9231.33);
INSERT INTO `dealers` VALUES (15, 'M072467', '余云熙', 9622.72);
INSERT INTO `dealers` VALUES (16, 'M004954', '李睿', 8419.61);
INSERT INTO `dealers` VALUES (17, 'M522723', '任詩涵', 5759.40);
INSERT INTO `dealers` VALUES (18, 'M877839', '曾睿', 5114.14);
INSERT INTO `dealers` VALUES (19, 'M440096', '何宇宁', 6906.13);

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of factories
-- ----------------------------
INSERT INTO `factories` VALUES (1, '武汉', '武汉', '张三', '12345678911');
INSERT INTO `factories` VALUES (2, '长沙', '上沙', '李四', '12321312312');
INSERT INTO `factories` VALUES (3, '广州', '广州', '王五', '18858642354');

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
  CONSTRAINT `factory_stocks_ibfk_1` FOREIGN KEY (`factory_id`) REFERENCES `factories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `factory_stocks_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products_spu` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of factory_stocks
-- ----------------------------

-- ----------------------------
-- Table structure for freight_logs
-- ----------------------------
DROP TABLE IF EXISTS `freight_logs`;
CREATE TABLE `freight_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `dealer_id` bigint NOT NULL COMMENT '经销商ID',
  `amount` decimal(18, 2) NOT NULL COMMENT '运费金额',
  `collected` tinyint NULL DEFAULT 0 COMMENT '是否已收取',
  `collected_at` datetime NULL DEFAULT NULL COMMENT '收取时间',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE,
  INDEX `dealer_id`(`dealer_id` ASC) USING BTREE,
  CONSTRAINT `freight_logs_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `freight_logs_ibfk_2` FOREIGN KEY (`dealer_id`) REFERENCES `dealers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
  `quantity` decimal(18, 2) NOT NULL COMMENT '商品数量',
  `unit_price` decimal(18, 2) NOT NULL COMMENT '单价',
  `total_price` decimal(18, 2) NOT NULL COMMENT '总价',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE,
  INDEX `product_id`(`product_id` ASC) USING BTREE,
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products_spu` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1101 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_items
-- ----------------------------
INSERT INTO `order_items` VALUES (1001, 20, 10003, 274.19, 709.50, 106.78);
INSERT INTO `order_items` VALUES (1002, 4, 10005, 882.69, 805.76, 929.63);
INSERT INTO `order_items` VALUES (1003, 5, 10029, 298.42, 516.49, 136.84);
INSERT INTO `order_items` VALUES (1004, 2, 10013, 866.57, 432.05, 832.62);
INSERT INTO `order_items` VALUES (1005, 19, 10016, 583.03, 742.72, 36.50);
INSERT INTO `order_items` VALUES (1006, 21, 10027, 86.67, 714.91, 935.53);
INSERT INTO `order_items` VALUES (1007, 15, 10006, 872.66, 704.41, 612.27);
INSERT INTO `order_items` VALUES (1008, 9, 10013, 516.40, 879.34, 512.12);
INSERT INTO `order_items` VALUES (1009, 15, 10027, 123.39, 528.43, 507.92);
INSERT INTO `order_items` VALUES (1010, 9, 10004, 478.13, 139.80, 619.50);
INSERT INTO `order_items` VALUES (1011, 8, 10003, 151.44, 846.30, 3.86);
INSERT INTO `order_items` VALUES (1012, 21, 10005, 739.96, 547.51, 461.65);
INSERT INTO `order_items` VALUES (1013, 15, 10004, 298.19, 915.91, 751.48);
INSERT INTO `order_items` VALUES (1014, 7, 10020, 421.34, 210.29, 144.29);
INSERT INTO `order_items` VALUES (1015, 8, 10006, 789.06, 250.81, 987.96);
INSERT INTO `order_items` VALUES (1016, 9, 10006, 681.97, 639.77, 764.37);
INSERT INTO `order_items` VALUES (1017, 3, 10028, 741.35, 902.49, 770.81);
INSERT INTO `order_items` VALUES (1018, 20, 10029, 994.74, 202.86, 359.65);
INSERT INTO `order_items` VALUES (1019, 9, 10019, 747.34, 348.88, 13.28);
INSERT INTO `order_items` VALUES (1020, 13, 10011, 41.93, 507.15, 435.93);
INSERT INTO `order_items` VALUES (1021, 9, 10002, 953.91, 495.97, 368.81);
INSERT INTO `order_items` VALUES (1022, 17, 10018, 656.67, 365.71, 995.32);
INSERT INTO `order_items` VALUES (1023, 13, 10019, 49.62, 794.31, 917.60);
INSERT INTO `order_items` VALUES (1024, 10, 10026, 217.56, 183.66, 336.02);
INSERT INTO `order_items` VALUES (1025, 5, 10011, 807.29, 135.71, 395.82);
INSERT INTO `order_items` VALUES (1026, 16, 10007, 654.23, 503.67, 350.49);
INSERT INTO `order_items` VALUES (1027, 14, 10028, 399.81, 715.36, 107.84);
INSERT INTO `order_items` VALUES (1028, 17, 10028, 870.92, 755.66, 503.62);
INSERT INTO `order_items` VALUES (1029, 15, 10018, 229.16, 793.00, 304.30);
INSERT INTO `order_items` VALUES (1030, 8, 10023, 421.91, 241.52, 96.50);
INSERT INTO `order_items` VALUES (1031, 9, 10004, 908.97, 786.10, 470.01);
INSERT INTO `order_items` VALUES (1032, 12, 10019, 357.47, 716.52, 240.72);
INSERT INTO `order_items` VALUES (1033, 15, 10021, 64.25, 554.38, 745.62);
INSERT INTO `order_items` VALUES (1034, 17, 10019, 712.92, 213.80, 531.77);
INSERT INTO `order_items` VALUES (1035, 19, 10012, 904.13, 599.97, 317.84);
INSERT INTO `order_items` VALUES (1036, 21, 10021, 228.73, 376.33, 780.55);
INSERT INTO `order_items` VALUES (1037, 14, 10013, 775.08, 762.40, 617.88);
INSERT INTO `order_items` VALUES (1038, 9, 10024, 619.41, 557.44, 822.88);
INSERT INTO `order_items` VALUES (1039, 20, 10004, 81.99, 969.01, 812.27);
INSERT INTO `order_items` VALUES (1040, 21, 10026, 115.38, 199.62, 770.24);
INSERT INTO `order_items` VALUES (1041, 19, 10015, 940.19, 328.56, 692.78);
INSERT INTO `order_items` VALUES (1042, 7, 10010, 399.87, 467.47, 39.12);
INSERT INTO `order_items` VALUES (1043, 8, 10030, 546.02, 654.46, 274.33);
INSERT INTO `order_items` VALUES (1044, 3, 10014, 452.08, 103.77, 489.63);
INSERT INTO `order_items` VALUES (1045, 10, 10023, 294.23, 331.90, 81.97);
INSERT INTO `order_items` VALUES (1046, 21, 10004, 441.04, 379.92, 635.25);
INSERT INTO `order_items` VALUES (1047, 17, 10023, 534.66, 877.35, 153.01);
INSERT INTO `order_items` VALUES (1048, 6, 10013, 734.65, 674.56, 272.16);
INSERT INTO `order_items` VALUES (1049, 5, 10007, 159.71, 415.04, 178.43);
INSERT INTO `order_items` VALUES (1050, 5, 10030, 205.05, 141.23, 817.46);
INSERT INTO `order_items` VALUES (1051, 7, 10017, 746.55, 798.38, 224.57);
INSERT INTO `order_items` VALUES (1052, 10, 10019, 803.14, 599.42, 228.17);
INSERT INTO `order_items` VALUES (1053, 12, 10017, 574.14, 475.06, 709.54);
INSERT INTO `order_items` VALUES (1054, 10, 10026, 508.27, 979.40, 26.14);
INSERT INTO `order_items` VALUES (1055, 5, 10013, 482.04, 142.63, 87.93);
INSERT INTO `order_items` VALUES (1056, 10, 10003, 765.86, 762.39, 315.43);
INSERT INTO `order_items` VALUES (1057, 3, 10002, 52.36, 393.62, 531.13);
INSERT INTO `order_items` VALUES (1058, 12, 10022, 53.49, 798.10, 688.44);
INSERT INTO `order_items` VALUES (1059, 21, 10018, 787.75, 790.87, 824.66);
INSERT INTO `order_items` VALUES (1060, 16, 10010, 841.97, 75.18, 446.92);
INSERT INTO `order_items` VALUES (1061, 14, 10002, 626.96, 817.32, 852.66);
INSERT INTO `order_items` VALUES (1062, 3, 10004, 921.46, 707.24, 950.57);
INSERT INTO `order_items` VALUES (1063, 5, 10024, 756.70, 884.88, 346.15);
INSERT INTO `order_items` VALUES (1064, 5, 10010, 924.05, 664.19, 306.21);
INSERT INTO `order_items` VALUES (1065, 11, 10030, 114.31, 395.24, 769.28);
INSERT INTO `order_items` VALUES (1066, 19, 10017, 522.16, 176.14, 975.40);
INSERT INTO `order_items` VALUES (1067, 7, 10006, 405.31, 369.64, 906.59);
INSERT INTO `order_items` VALUES (1068, 17, 10018, 386.81, 899.30, 898.83);
INSERT INTO `order_items` VALUES (1069, 5, 10023, 44.87, 733.34, 703.84);
INSERT INTO `order_items` VALUES (1070, 21, 10020, 20.24, 391.09, 495.26);
INSERT INTO `order_items` VALUES (1071, 21, 10020, 150.87, 356.21, 454.98);
INSERT INTO `order_items` VALUES (1072, 12, 10023, 127.56, 508.06, 442.82);
INSERT INTO `order_items` VALUES (1073, 6, 10022, 64.81, 445.28, 833.08);
INSERT INTO `order_items` VALUES (1074, 11, 10010, 403.58, 792.14, 7.08);
INSERT INTO `order_items` VALUES (1075, 3, 10011, 100.05, 201.61, 720.17);
INSERT INTO `order_items` VALUES (1076, 16, 10007, 881.84, 537.93, 720.07);
INSERT INTO `order_items` VALUES (1077, 13, 10009, 375.99, 254.63, 566.44);
INSERT INTO `order_items` VALUES (1078, 12, 10027, 101.18, 199.13, 896.29);
INSERT INTO `order_items` VALUES (1079, 12, 10019, 440.08, 626.91, 384.86);
INSERT INTO `order_items` VALUES (1080, 8, 10006, 6.85, 626.18, 521.10);
INSERT INTO `order_items` VALUES (1081, 21, 10023, 147.79, 728.55, 340.37);
INSERT INTO `order_items` VALUES (1082, 5, 10017, 252.47, 606.55, 257.69);
INSERT INTO `order_items` VALUES (1083, 9, 10028, 430.90, 73.98, 224.12);
INSERT INTO `order_items` VALUES (1084, 19, 10019, 553.57, 933.55, 98.76);
INSERT INTO `order_items` VALUES (1085, 14, 10012, 687.90, 335.97, 717.53);
INSERT INTO `order_items` VALUES (1086, 6, 10010, 395.13, 238.59, 280.29);
INSERT INTO `order_items` VALUES (1087, 6, 10028, 798.66, 981.50, 720.04);
INSERT INTO `order_items` VALUES (1088, 18, 10024, 179.74, 93.57, 891.50);
INSERT INTO `order_items` VALUES (1089, 5, 10008, 436.19, 566.43, 764.56);
INSERT INTO `order_items` VALUES (1090, 19, 10017, 135.68, 757.74, 762.46);
INSERT INTO `order_items` VALUES (1091, 19, 10017, 914.00, 817.18, 502.48);
INSERT INTO `order_items` VALUES (1092, 19, 10028, 608.55, 376.32, 294.02);
INSERT INTO `order_items` VALUES (1093, 10, 10028, 745.28, 456.53, 553.58);
INSERT INTO `order_items` VALUES (1094, 6, 10020, 278.73, 120.10, 223.09);
INSERT INTO `order_items` VALUES (1095, 13, 10001, 999.67, 171.62, 359.77);
INSERT INTO `order_items` VALUES (1096, 16, 10017, 205.71, 841.32, 454.43);
INSERT INTO `order_items` VALUES (1097, 11, 10023, 841.34, 436.77, 47.57);
INSERT INTO `order_items` VALUES (1098, 9, 10008, 700.77, 533.27, 474.42);
INSERT INTO `order_items` VALUES (1099, 5, 10023, 893.57, 371.41, 179.02);
INSERT INTO `order_items` VALUES (1100, 20, 10026, 715.73, 1.32, 217.84);

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
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE,
  CONSTRAINT `order_logs_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_logs
-- ----------------------------

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `dealer_id` bigint NULL DEFAULT NULL COMMENT '经销商ID',
  `factory_id` bigint NULL DEFAULT NULL COMMENT '工厂ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单状态：待审核/已审核/待发货/已发货/已完成/已取消',
  `total_amount` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '订单总金额',
  `freight` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '运费',
  `receiver_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人电话',
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货地址',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `order_no`(`order_no` ASC) USING BTREE,
  INDEX `customer_id`(`customer_id` ASC) USING BTREE,
  INDEX `dealer_id`(`dealer_id` ASC) USING BTREE,
  INDEX `factory_id`(`factory_id` ASC) USING BTREE,
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`dealer_id`) REFERENCES `dealers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`factory_id`) REFERENCES `factories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (2, 'NUATufmVFB', 198, 8, 3, '0', 39.58, 893.47, '赵子韬', '195-0650-0365', '京华商圈华夏街439号', 'v6JX1usXze', 708, '2024-07-08 03:04:28', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (3, 'VaaTJ8xFE9', 162, 7, 1, '0', 550.18, 184.06, '韦睿', '20-470-3635', '天河区天河路729号', '6Bu40k8gkJ', 17, '2022-12-19 11:46:21', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (4, 'e78JzQ20y0', 129, 13, 3, '0', 239.21, 981.27, '何詩涵', '20-7572-7495', '越秀区中山二路317号', 'reV71xs82Y', 425, '2019-10-22 01:48:13', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (5, 'mdkHADrxtS', 149, 10, 3, '0', 767.86, 34.70, '萧震南', '760-801-7560', '天河区大信商圈大信南路859号', 'NMbGCDarCi', 499, '2022-04-14 03:42:05', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (6, '6CxUoJacHH', 132, 1, 3, '0', 896.04, 987.71, '汤致远', '139-3593-1559', '福田区景田东一街502号', 'RKl6IOCZxA', 862, '2006-12-21 14:19:16', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (7, 'QlpOZeMR4e', 168, 4, 1, '0', 108.77, 361.81, '萧詩涵', '133-8400-9319', '東城区東直門內大街92号', 'oTW39TZSVA', 30, '2025-01-14 15:25:35', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (8, 'mLGkVqGzQ3', 128, 18, 3, '0', 29.10, 241.25, '余云熙', '157-0539-3477', '罗湖区蔡屋围深南东路414号', 'ikPH3U4aRx', 383, '2018-12-17 22:51:55', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (9, 'zugvmtbs0F', 125, 1, 2, '0', 430.91, 921.19, '薛致远', '10-760-5551', '延庆区028县道477号', 'VffaKWlbX0', 947, '2017-04-20 00:37:25', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (10, 'v5n6iaNtWW', 116, 2, 2, '0', 576.22, 140.28, '傅宇宁', '146-9817-1189', '越秀区中山二路547号', 'YTish6sz0r', 509, '2001-12-04 11:29:40', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (11, 'nYPh37jRVL', 188, 14, 3, '0', 869.17, 198.47, '曹睿', '20-142-6165', '天河区天河路18号', 'v1NuGlxq8h', 100, '2009-05-27 09:23:32', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (12, 'GNXfaeYfPi', 145, 7, 1, '0', 966.80, 591.93, '丁岚', '755-1797-2727', '罗湖区蔡屋围深南东路840号', 'XeSqbo9YZ7', 692, '2005-10-28 05:06:37', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (13, 'vL7qI4kels', 185, 16, 3, '0', 310.21, 477.42, '王璐', '10-949-0067', '东城区东单王府井东街710号', 'b9mFseCCdr', 276, '2003-01-23 13:53:58', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (14, '6F13Ards1j', 179, 12, 1, '0', 497.63, 416.95, '崔璐', '155-8402-7602', '龙岗区学园一巷848号', 'kQMsgus3df', 364, '2008-10-23 05:13:50', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (15, 'LVzRqjTLZu', 106, 15, 3, '0', 369.82, 966.61, '傅震南', '10-531-6087', '房山区岳琉路310号', 'BxZRcm7fCj', 342, '2011-07-22 13:00:32', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (16, '60Ihi5tpJ7', 164, 19, 3, '0', 412.42, 603.87, '程子韬', '10-613-0214', '西城区复兴门内大街211号', 'eSD3N1fOma', 83, '2013-12-26 01:55:20', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (17, '4FZSH5afJT', 126, 7, 3, '0', 787.24, 420.33, '曹震南', '760-2254-4407', '紫马岭商圈中山五路447号', 'rAX7eXwkRI', 360, '2005-05-12 22:06:47', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (18, 'Dq57T4az6j', 162, 13, 2, '0', 179.11, 134.44, '曾震南', '132-9170-1940', '龙岗区布吉镇西环路851号', 'DIWaJQ6pCr', 586, '2001-06-18 19:13:03', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (19, 'xpUlkVuyOt', 159, 13, 1, '0', 972.25, 94.04, '杨震南', '28-541-7796', '成华区二仙桥东三路568号', '9bi3J5BC3z', 223, '2005-10-06 12:08:48', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (20, 'Bud3CtNnUY', 126, 13, 2, '0', 122.56, 727.00, '任云熙', '162-0501-3404', '龙岗区学园一巷537号', 'hY0b3wRiFf', 252, '2006-03-03 12:35:19', '2025-06-13 15:14:27');
INSERT INTO `orders` VALUES (21, 'RnkTerg1wi', 152, 8, 2, '0', 391.07, 608.89, '傅璐', '147-5774-0942', '海珠区江南西路355号', 'UjgqOurhmJ', 889, '2010-11-07 05:25:59', '2025-06-13 15:14:27');

-- ----------------------------
-- Table structure for orders_history
-- ----------------------------
DROP TABLE IF EXISTS `orders_history`;
CREATE TABLE `orders_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `dealer_id` bigint NULL DEFAULT NULL COMMENT '经销商ID',
  `factory_id` bigint NULL DEFAULT NULL COMMENT '工厂ID',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单状态：待审核/已审核/待发货/已发货/已完成/已取消',
  `total_amount` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '订单总金额',
  `freight` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '运费',
  `receiver_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人电话',
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货地址',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` bigint NULL DEFAULT NULL COMMENT '创建人ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `order_no`(`order_no` ASC) USING BTREE,
  INDEX `customer_id`(`customer_id` ASC) USING BTREE,
  INDEX `dealer_id`(`dealer_id` ASC) USING BTREE,
  INDEX `factory_id`(`factory_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders_history
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
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE,
  UNIQUE INDEX `code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of permissions
-- ----------------------------
INSERT INTO `permissions` VALUES (1, '创建用户', 'user.create', '创建用户');
INSERT INTO `permissions` VALUES (2, '查询用户', 'user.select', 'cx');
INSERT INTO `permissions` VALUES (3, '更新用户', 'user.update', 'up');
INSERT INTO `permissions` VALUES (4, '删除用户', 'user.delete', 'de');

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
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `brand_id` bigint NULL DEFAULT NULL COMMENT '品牌ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '分类ID（指向二级分类）',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计量单位',
  `special_rule` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '特殊计量规则，如3件扣1',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `brand_id`(`brand_id` ASC) USING BTREE,
  INDEX `category_id`(`category_id` ASC) USING BTREE,
  CONSTRAINT `products_sku_ibfk_1` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `products_sku_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10031 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of products_sku
-- ----------------------------
INSERT INTO `products_sku` VALUES (10001, '抗皱霜', 1002, 10, '箱', 'H9dWo6jIrR', 1, '2002-10-20 03:42:34');
INSERT INTO `products_sku` VALUES (10002, '蜜都安睡裤', 1010, 4, '套', 'x1mM7BCb07', 0, '2003-10-12 19:13:19');
INSERT INTO `products_sku` VALUES (10003, '蜜都舒缓修护柔肤套', 1008, 13, '瓶', 'fzGlLLlaeA', 0, '2008-06-09 01:51:56');
INSERT INTO `products_sku` VALUES (10004, '沐浴露', 1001, 2, '瓶', 'ROAsBbZ3iT', 0, '2001-08-27 14:01:03');
INSERT INTO `products_sku` VALUES (10005, '洗衣液', 1008, 1, '套', 'ONxVd26YnS', 0, '2000-05-20 05:08:38');
INSERT INTO `products_sku` VALUES (10006, '防晒霜', 1002, 6, '套', 'fSrETvi2Ad', 0, '2001-11-22 20:51:47');
INSERT INTO `products_sku` VALUES (10007, '隔离', 1002, 2, '箱', 'RA7g3OGQXW', 1, '2015-02-15 05:22:07');
INSERT INTO `products_sku` VALUES (10008, '沐浴露', 1002, 10, '件', 'SeY5cKn2oS', 1, '2017-10-30 12:58:22');
INSERT INTO `products_sku` VALUES (10009, '新冰膜+3支喷雾', 1003, 14, '件', 'k27GXc18JO', 1, '2017-07-28 02:46:58');
INSERT INTO `products_sku` VALUES (10010, '蜜都安睡裤', 1002, 5, '瓶', 'epDHkOTOUv', 0, '2013-12-20 10:08:24');
INSERT INTO `products_sku` VALUES (10011, '新冰膜+3支喷雾', 1006, 14, '件', 'Hu2aIYga0S', 1, '2024-04-30 22:41:01');
INSERT INTO `products_sku` VALUES (10012, '贵妇膏', 1004, 12, '箱', 'LJBIVqh4an', 0, '2009-04-05 06:10:01');
INSERT INTO `products_sku` VALUES (10013, '24K金/水', 1009, 8, '瓶', 'yvICdEEgYJ', 0, '2015-01-03 15:09:48');
INSERT INTO `products_sku` VALUES (10014, '洗衣液', 1008, 14, '瓶', 'MEDs4jwZtL', 0, '2011-09-16 01:00:01');
INSERT INTO `products_sku` VALUES (10015, '补水喷雾', 1009, 10, '件', 'IuPiEehdGd', 0, '2002-08-27 02:12:10');
INSERT INTO `products_sku` VALUES (10016, '赠送小安瓶', 1008, 4, '件', 'XqZiHSKEmQ', 0, '2010-02-19 11:30:53');
INSERT INTO `products_sku` VALUES (10017, '24K金/精华', 1002, 6, '箱', 'osEAw9YBuK', 0, '2001-03-14 20:05:29');
INSERT INTO `products_sku` VALUES (10018, '玻尿酸', 1010, 11, '套', 'bWBV1CSgLU', 1, '2016-11-27 00:51:54');
INSERT INTO `products_sku` VALUES (10019, '内衣洗衣液', 1002, 3, '件', 'bfxu8xSuiO', 1, '2020-07-06 08:09:10');
INSERT INTO `products_sku` VALUES (10020, '贵妇膏', 1009, 9, '瓶', 'kX0nY0SIYp', 1, '2016-06-05 13:31:58');
INSERT INTO `products_sku` VALUES (10021, '玻尿酸', 1001, 14, '瓶', 'IKynTM65FY', 0, '2003-08-22 11:58:08');
INSERT INTO `products_sku` VALUES (10022, '生姜洗发水', 1006, 13, '件', 'yQ3UEsUNaq', 1, '2009-02-14 08:21:01');
INSERT INTO `products_sku` VALUES (10023, '新款控油洗发', 1006, 4, '套', 'QCjBpAyJV0', 0, '2020-07-15 05:19:34');
INSERT INTO `products_sku` VALUES (10024, '香氛洗发水', 1010, 8, '件', 'y5l517tcMg', 1, '2003-07-17 22:56:22');
INSERT INTO `products_sku` VALUES (10025, '卫生巾', 1001, 9, '套', '2iwOr6g5lc', 1, '2007-12-18 20:41:16');
INSERT INTO `products_sku` VALUES (10026, '冰膜', 1006, 14, '瓶', 'SdbbwzauQn', 0, '2001-05-06 11:48:25');
INSERT INTO `products_sku` VALUES (10027, '24K金/乳', 1002, 2, '瓶', '92NBFubci8', 0, '2019-09-03 21:40:10');
INSERT INTO `products_sku` VALUES (10028, '抗皱霜', 1005, 9, '瓶', '1QBlDSEeSf', 1, '2003-09-04 18:35:08');
INSERT INTO `products_sku` VALUES (10029, '玻尿酸', 1002, 4, '套', 'wAayxJxGCu', 1, '2012-10-17 07:19:05');
INSERT INTO `products_sku` VALUES (10030, '去屑洗发水', 1006, 7, '瓶', 'G67l4Ow2of', 1, '2022-02-20 08:48:08');

-- ----------------------------
-- Table structure for products_spu
-- ----------------------------
DROP TABLE IF EXISTS `products_spu`;
CREATE TABLE `products_spu`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名称',
  `brand_id` bigint NULL DEFAULT NULL COMMENT '品牌ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '分类ID（指向二级分类）',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计量单位',
  `special_rule` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '特殊计量规则，如3件扣1',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `brand_id`(`brand_id` ASC) USING BTREE,
  INDEX `category_id`(`category_id` ASC) USING BTREE,
  CONSTRAINT `products_spu_ibfk_1` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `products_spu_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10031 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of products_spu
-- ----------------------------
INSERT INTO `products_spu` VALUES (10001, '抗皱霜', 1002, 10, '箱', 'H9dWo6jIrR', 1, '2002-10-20 03:42:34');
INSERT INTO `products_spu` VALUES (10002, '蜜都安睡裤', 1010, 4, '套', 'x1mM7BCb07', 0, '2003-10-12 19:13:19');
INSERT INTO `products_spu` VALUES (10003, '蜜都舒缓修护柔肤套', 1008, 13, '瓶', 'fzGlLLlaeA', 0, '2008-06-09 01:51:56');
INSERT INTO `products_spu` VALUES (10004, '沐浴露', 1001, 2, '瓶', 'ROAsBbZ3iT', 0, '2001-08-27 14:01:03');
INSERT INTO `products_spu` VALUES (10005, '洗衣液', 1008, 1, '套', 'ONxVd26YnS', 0, '2000-05-20 05:08:38');
INSERT INTO `products_spu` VALUES (10006, '防晒霜', 1002, 6, '套', 'fSrETvi2Ad', 0, '2001-11-22 20:51:47');
INSERT INTO `products_spu` VALUES (10007, '隔离', 1002, 2, '箱', 'RA7g3OGQXW', 1, '2015-02-15 05:22:07');
INSERT INTO `products_spu` VALUES (10008, '沐浴露', 1002, 10, '件', 'SeY5cKn2oS', 1, '2017-10-30 12:58:22');
INSERT INTO `products_spu` VALUES (10009, '新冰膜+3支喷雾', 1003, 14, '件', 'k27GXc18JO', 1, '2017-07-28 02:46:58');
INSERT INTO `products_spu` VALUES (10010, '蜜都安睡裤', 1002, 5, '瓶', 'epDHkOTOUv', 0, '2013-12-20 10:08:24');
INSERT INTO `products_spu` VALUES (10011, '新冰膜+3支喷雾', 1006, 14, '件', 'Hu2aIYga0S', 1, '2024-04-30 22:41:01');
INSERT INTO `products_spu` VALUES (10012, '贵妇膏', 1004, 12, '箱', 'LJBIVqh4an', 0, '2009-04-05 06:10:01');
INSERT INTO `products_spu` VALUES (10013, '24K金/水', 1009, 8, '瓶', 'yvICdEEgYJ', 0, '2015-01-03 15:09:48');
INSERT INTO `products_spu` VALUES (10014, '洗衣液', 1008, 14, '瓶', 'MEDs4jwZtL', 0, '2011-09-16 01:00:01');
INSERT INTO `products_spu` VALUES (10015, '补水喷雾', 1009, 10, '件', 'IuPiEehdGd', 0, '2002-08-27 02:12:10');
INSERT INTO `products_spu` VALUES (10016, '赠送小安瓶', 1008, 4, '件', 'XqZiHSKEmQ', 0, '2010-02-19 11:30:53');
INSERT INTO `products_spu` VALUES (10017, '24K金/精华', 1002, 6, '箱', 'osEAw9YBuK', 0, '2001-03-14 20:05:29');
INSERT INTO `products_spu` VALUES (10018, '玻尿酸', 1010, 11, '套', 'bWBV1CSgLU', 1, '2016-11-27 00:51:54');
INSERT INTO `products_spu` VALUES (10019, '内衣洗衣液', 1002, 3, '件', 'bfxu8xSuiO', 1, '2020-07-06 08:09:10');
INSERT INTO `products_spu` VALUES (10020, '贵妇膏', 1009, 9, '瓶', 'kX0nY0SIYp', 1, '2016-06-05 13:31:58');
INSERT INTO `products_spu` VALUES (10021, '玻尿酸', 1001, 14, '瓶', 'IKynTM65FY', 0, '2003-08-22 11:58:08');
INSERT INTO `products_spu` VALUES (10022, '生姜洗发水', 1006, 13, '件', 'yQ3UEsUNaq', 1, '2009-02-14 08:21:01');
INSERT INTO `products_spu` VALUES (10023, '新款控油洗发', 1006, 4, '套', 'QCjBpAyJV0', 0, '2020-07-15 05:19:34');
INSERT INTO `products_spu` VALUES (10024, '香氛洗发水', 1010, 8, '件', 'y5l517tcMg', 1, '2003-07-17 22:56:22');
INSERT INTO `products_spu` VALUES (10025, '卫生巾', 1001, 9, '套', '2iwOr6g5lc', 1, '2007-12-18 20:41:16');
INSERT INTO `products_spu` VALUES (10026, '冰膜', 1006, 14, '瓶', 'SdbbwzauQn', 0, '2001-05-06 11:48:25');
INSERT INTO `products_spu` VALUES (10027, '24K金/乳', 1002, 2, '瓶', '92NBFubci8', 0, '2019-09-03 21:40:10');
INSERT INTO `products_spu` VALUES (10028, '抗皱霜', 1005, 9, '瓶', '1QBlDSEeSf', 1, '2003-09-04 18:35:08');
INSERT INTO `products_spu` VALUES (10029, '玻尿酸', 1002, 4, '套', 'wAayxJxGCu', 1, '2012-10-17 07:19:05');
INSERT INTO `products_spu` VALUES (10030, '去屑洗发水', 1006, 7, '瓶', 'G67l4Ow2of', 1, '2022-02-20 08:48:08');

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
  CONSTRAINT `shipment_items_ibfk_1` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `shipment_items_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `shipment_items_ibfk_3` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `user_roles` VALUES (5, 5);
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
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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

SET FOREIGN_KEY_CHECKS = 1;
