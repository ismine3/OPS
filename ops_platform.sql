/*
 Navicat Premium Dump SQL

 Source Server         : 192.168.1.124
 Source Server Type    : MySQL
 Source Server Version : 80040 (8.0.40)
 Source Host           : 192.168.1.124:3306
 Source Schema         : ops_platform

 Target Server Type    : MySQL
 Target Server Version : 80040 (8.0.40)
 File Encoding         : 65001

 Date: 10/04/2026 15:26:01
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for accounts
-- ----------------------------
DROP TABLE IF EXISTS `accounts`;
CREATE TABLE `accounts`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `seq_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '编号',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '应用名称',
  `company` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所属单位',
  `access_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '访问地址',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名',
  `password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '密码',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `project_id` int NULL DEFAULT NULL COMMENT '所属项目ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 82 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '应用系统台账表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of accounts
-- ----------------------------
INSERT INTO `accounts` VALUES (62, 'TYY-01', '天翼云官网', '成都海生科技有限公司', 'https://www.ctyun.cn/h5/activity/2022/index', '4341884@qq.com', 'gAAAAABp0pCBxR6S-RRpLSJhha0DH-46xgtikCO36Y0ujRgszQUGlFO-tbluBbpzR_Th6PTh0FYyNiv1BRjAvkLXuCgt0iFxoQ==', '绑定手机号：13568915745  何小虎', '2026-04-03 09:19:29', '2026-04-05 16:40:33', 1);
INSERT INTO `accounts` VALUES (63, 'TYY-02', '天翼云官网', '四川世纪纵辰科技有限责任公司', 'https://www.ctyun.cn/h5/activity/2022/index', '四川世纪纵辰实业有限责任公司', 'gAAAAABpz4s8Np0TLPYhsRbu0em_23O8cXuE_fBEVrsnfzx92Klj7tYQh07nvrWP9Xkjwp2aYpbgH2mmOjRJL45OTOcxRX2sVw==', '绑定手机号：18382396904', '2026-04-03 09:20:23', '2026-04-03 09:41:16', NULL);
INSERT INTO `accounts` VALUES (64, 'ALY-01', '阿里云官网', '成都华泽数智信息技术有限公司', 'https://account.aliyun.com/login/login.htm?spm', '华泽数智', 'gAAAAABpz4tWJ2E-hJLMY-gcYhLKFP_wo5PjJ2kBCw_I678sWj8f5VkLIrS3w9BOW37HE9770GE-lPwT2zrFss3zfMmNwqV_RA==', '验证码找袁聪', '2026-04-03 09:31:39', '2026-04-03 09:41:42', NULL);
INSERT INTO `accounts` VALUES (65, 'ALY-02', '阿里云官网', '四川世纪纵辰科技有限公司', 'https://account.aliyun.com/login/login.htm?spm', '世纪纵辰', 'gAAAAABp0yrBJi6eHDoRG-hbjiEjHRiyfdW8Ouo5CcUffJ0g92yL-eFu2IQWL21yqh8kDdOVoZP4S9HFwZSSDwbD6YCjaen8dQ==', '绑定手机号：18108272620  陈洁', '2026-04-03 09:39:29', '2026-04-06 03:38:41', 2);
INSERT INTO `accounts` VALUES (66, 'ALY-03', '阿里云官网', '成都天宇新创智能科技有限公司', 'https://account.aliyun.com/login/login.htm?spm', '天宇01', 'gAAAAABpz4u4r6UnbutEaqIsVqk05x5dCfrWCPTgfka5Fev1Kn07PSuiVgIxVE5-Tm6IwqmOo0Ht7XbWwSNjF1Uvn-UvgBQX8A==', '岷江水务项目购买的ssl证书（到期时间2024年6月25日、费用1020元/年）\n（该云上暂无资源）', '2026-04-03 09:43:20', '2026-04-03 09:43:20', NULL);
INSERT INTO `accounts` VALUES (67, 'ALY-04', '阿里云官网', '成都海生科技有限公司', 'https://account.aliyun.com/login/login.htm?spm', 'hskjdd', 'gAAAAABpz4v5YgSWW345tOOaq-9zu1Z6nvb1Cl1TBFIkr_LnkNKxKOqwMfsbddnel1TGl7oPxiVMRt8tFQE5lfSQztdrZlZx9w==', '水电平台ssl测试证书', '2026-04-03 09:44:07', '2026-04-03 09:44:25', NULL);
INSERT INTO `accounts` VALUES (68, 'ALY-05', '阿里云官网', '四川世纪纵辰实业有限公司成都分公司', 'https://account.aliyun.com/login/login.htm?spm', 'sjzccf', 'gAAAAABpz4w92ySEoBgjb1E1RjHZP4eL3lM_aNTU37Wp04bjxpcIKzuHRYAwIJbyYeo5sP2jIj8w2YyXboHsYCotOAaRudvAAg==', '绑定人:何小虎', '2026-04-03 09:45:33', '2026-04-03 09:45:33', NULL);
INSERT INTO `accounts` VALUES (69, '', 'confluence', '四川世纪纵辰科技有限公司', 'http://112.45.109.134:29890/', 'admin', 'gAAAAABp2JxlCAFclS6pndasuVVtkZVUkyrbPCkbQ1vhvR0fg3gZ5e284dpKRKj5qb4BXzl_cAFAvMTEzz8bxEiT91ty9zXAoA==', '', '2026-04-10 06:44:53', '2026-04-10 06:44:53', 10);
INSERT INTO `accounts` VALUES (70, '', '禅道', '四川世纪纵辰科技有限公司', 'http://112.45.109.134:52880/my.html', 'wuxiansheng', 'gAAAAABp2J0A2TjN_YNzKXRwTeyyIZBj5Go9z-3nB9J8pYlAtxpyx-cXQ_8idj93h_dW761g3NOvwKu9NBU_h1J1TPoTGPKp1g==', '', '2026-04-10 06:47:28', '2026-04-10 06:47:28', 10);
INSERT INTO `accounts` VALUES (71, '', '堡垒机', '四川世纪纵辰科技有限公司', 'http://112.45.109.134:8111/ui/#/profile/improvement', 'admin', 'gAAAAABp2J1L76hZG_RdC9q8WpGAOKMXJA2_ZggBmrEZKKfnnYsOZBUuOD6hb9TyuZzVnKT3ejyI9kzxCpJuIJQLOiqUMBWSJA==', '', '2026-04-10 06:48:43', '2026-04-10 06:48:43', 10);
INSERT INTO `accounts` VALUES (72, 'HARBOR-02', 'harbor', '四川世纪纵辰科技有限公司', 'http://112.45.109.134:11280/harbor/projects', 'admin', 'gAAAAABp2J2f7FP6pBJSFLDcJfO6o-WrTdKdVQ5FmKQOLhiSdCAHY9Sc6ivyS0YKJs14NMWypPG4Xz6vnoIv6ICoquzXH1gPdQ==', '', '2026-04-10 06:50:07', '2026-04-10 06:50:07', 9);
INSERT INTO `accounts` VALUES (73, 'JENKINS-02', 'Jenkins', '四川世纪纵辰科技有限公司', 'http://112.45.109.134:18080/  ', 'root', 'gAAAAABp2J3eyb1V4qzfCgEnFLHiShjSwh3CYGIYgHS84wJfslz0a3WZGzt7tF3T0i-lcFBASn9Yz6fLUzu-Q_Ci4Yj8W1q92n2HGLEi_KG86ywZTdDN3IxaXdT8JD_SIMTdsqriWzX7', '待迁移至Jenkins master', '2026-04-10 06:51:10', '2026-04-10 06:51:10', 9);
INSERT INTO `accounts` VALUES (74, 'JENKINS-01', 'Jenkins', '四川世纪纵辰科技有限公司', 'http://112.45.109.134:17318/', 'root', 'gAAAAABp2J4WEfwk4LjKbDgissxRhhzxUo50y6EYH6faJbU_fL5XjwctXKPYo1kB0SabAhzcQOMkvO4qcmkwklvVrsUEuzTvTNiP-FUWtK580zCTSeHqTdk=', 'Jenkins master', '2026-04-10 06:51:55', '2026-04-10 06:52:06', 9);
INSERT INTO `accounts` VALUES (75, 'HARBOR-01', 'harbor', '四川世纪纵辰科技有限公司', 'https://harbor.huazsz.com/harbor/projects', 'admin', 'gAAAAABp2J6B4Og0PjO4N0DIC_RZe9N7pi6b-o80XiJgevz_BFCnAJUVV3FQ3aIpL4Q4BKpIHwJn99G7rI9NLg3ghNa0g4B60g==', 'harbor主仓库\nhttps://harbor.huazsz.com:17313/harbor/projects\n外网地址需要修改本机host解析至：112.45.109.134', '2026-04-10 06:53:53', '2026-04-10 06:53:53', 9);
INSERT INTO `accounts` VALUES (76, '', 'ubuntu-desktop', '四川世纪纵辰科技有限公司', 'https://112.45.109.134:31901/', 'kasm_user', 'gAAAAABp2J6yhpfq7bcPeSRsgnxN5jadjo7n5TvCUGErPmhBLOH4tF0ZIwH50yAA7BS6kh6xvteFCzukdqqgonGZ-XkS_7W5fg==', 'ubuntu  vnc', '2026-04-10 06:54:42', '2026-04-10 06:54:42', NULL);
INSERT INTO `accounts` VALUES (77, '', 'car-nacos-prod', '四川世纪纵辰科技有限公司', 'http://172.24.11.7:8848/nacos', 'nacos', 'gAAAAABp2J8NEnlT8pUtfMyGX8PfF7MbMQ-cA_IYdDLW4cQ0Sb6Hh-Fosm7Z_ITdrAGGmyCYW2jBQz6mweNvHCen9PntdFmtzHbU-A_X9lOmiYU_PLrVqDk=', '', '2026-04-10 06:56:13', '2026-04-10 06:56:13', 6);
INSERT INTO `accounts` VALUES (78, '', '数据中台H5', '四川世纪纵辰科技有限公司', 'http://h5.sjzctg.com', '', NULL, '', '2026-04-10 06:57:25', '2026-04-10 06:57:25', 3);
INSERT INTO `accounts` VALUES (79, '', '数据中台PC', '四川世纪纵辰科技有限公司', 'http://sdc.sjzctg.com', '', NULL, '', '2026-04-10 06:58:02', '2026-04-10 06:58:02', 3);
INSERT INTO `accounts` VALUES (80, 'HARBOR-03', 'harbor', '四川水电', 'https://scsd.huazsz.com/harbor', 'admin', 'gAAAAABp2J_DI4Xaf19HHJJ2xmFEDhljwZhJtLX5r6VdCUQjL4_lJ4LzmTz3U7GjhXlf2ANa3ifldio6TbWMM-SZdIN0u4hEGw==', '四川水电项目内网harbor仓库', '2026-04-10 06:59:15', '2026-04-10 06:59:15', 2);
INSERT INTO `accounts` VALUES (81, '', 'scsd-nacos-prod', '四川水电', 'http://10.11.2.38:8848', 'admin', 'gAAAAABp2KA1G6pWDZp-666ahJw5U_9ow5n0JlOpbT65YbdSHJL4NUPKQgyJsG-mn4NsLC2bLkWHPJbZ_wd8kPAm56m4QzZTBg==', '', '2026-04-10 06:59:55', '2026-04-10 07:01:09', 2);

-- ----------------------------
-- Table structure for change_records
-- ----------------------------
DROP TABLE IF EXISTS `change_records`;
CREATE TABLE `change_records`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `seq_no` int NULL DEFAULT NULL COMMENT '序号',
  `change_date` date NULL DEFAULT NULL COMMENT '日期',
  `modifier` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '修改人',
  `location` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '修改位置',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '修改内容',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_change_date`(`change_date` ASC) USING BTREE,
  INDEX `idx_modifier`(`modifier` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 101 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '更新记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of change_records
-- ----------------------------
INSERT INTO `change_records` VALUES (1, 1, '2024-04-18', '袁聪', '应用系统台账表', '添加：天宇阿里云的账号', '添加：天宇的账号', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (2, 2, '2024-04-18', '袁聪', '小程序（阿里云+微信）', '添加：岷江水务的ssl证书信息与到期时间', '添加：岷江水务的ssl证书信息与到期时间', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (3, 3, '2024-05-08', '杨伟', '应用系统台账表', '添加：世纪纵辰阿里云账号密码', '添加：世纪纵辰阿里云账号密码', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (4, 4, '2024-05-07', '袁聪', '小程序（阿里云+微信）', '添加：超级管理员字段。【停车场/充电宝】小程序的超级管理员为赵欣宇。服务号超级管理员为：王珂柚。都已交接完毕', '添加：超级管理员字段，已交接完毕', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (5, 5, '2024-05-21', '袁聪', '应用系统台账表', '添加：世纪纵辰阿里云账号的短信的配置信息', '添加：世纪纵辰阿里云账号的短信的配置信息（附件与批注）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (6, 6, '2024-06-14', '杨伟', '应用系统台账表', '添加：世纪纵辰OA综合管理系统分布式测试环境账号密码', '添加：世纪纵辰OA综合管理系统分布式测试环境账号密码', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (7, 7, '2024-06-14', '杨伟', '世纪纵辰-OA综合管理系统', '添加：世纪纵辰OA综合管理系统台账表', '添加：世纪纵辰OA综合管理系统台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (8, 8, '2024-07-10', '袁聪', '小程序（阿里云+微信）', '更新：域名、ssl证书、小程序的有效期与备注（为负数的未更新），', '更新:小程序的有效期', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (9, 8, '2024-07-10', '袁聪', '小程序（阿里云+微信）', NULL, '更新：域名有效期（为负数的未更新），', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (10, 8, '2024-07-10', '袁聪', '小程序（阿里云+微信）', NULL, '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (11, 8, '2024-07-10', '袁聪', '小程序（阿里云+微信）', NULL, '更新：ssl证书的有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (12, 8, '2024-07-10', '袁聪', '小程序（阿里云+微信）', NULL, '更新：ssl证书的备注（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (13, 9, '2024-08-05', '杨伟', '应用系统台账表', '增加系统运维账号', '更新：系统运维账号', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (14, 10, '2024-08-05', '杨伟', '应用系统台账表', '更新天翼云登录密码', '更新：天翼云登录账号密码', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (15, 11, '2024-08-21', '袁聪', '应用系统台账表', '添加：世纪纵辰的天翼云账号', '添加：世纪纵辰的天翼云账号', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (16, 12, '2024-08-22', '苏明超', '服务器台账规划表', '添加：世纪纵辰研发测试环境服务器规划', '添加：世纪纵辰研发测试环境服务器规划', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (17, 13, '2024-08-30', '袁聪', '应用系统台账表', '添加：高德开发平台', '添加：高德开发平台', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (18, 14, '2024-08-30', '袁聪', '小程序（阿里云+微信）', '添加：会议小程序信息', '添加：会议小程序信息', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (19, 14, '2024-08-30', '袁聪', '小程序（阿里云+微信）', '添加：会议小程序到期时间', '添加：会议小程序到期时间', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (20, 14, '2024-08-30', '袁聪', '小程序（阿里云+微信）', '添加：世纪域名到期时间', '添加：世纪域名到期时间', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (21, 14, '2024-08-30', '袁聪', '小程序（阿里云+微信）', '添加：世纪短信到期时间', '添加：世纪短信到期时间', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (22, 15, '2024-09-02', '杨伟', '应用系统台账表', '添加：世纪-OA综合管理系统正式环境1、2、3', '添加：世纪-OA综合管理系统正式环境1、2、3', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (23, 16, '2024-09-14', '袁聪', '小程序（阿里云+微信）', '添加：会议系统正式的ssl证书有效期', '添加：会议系统的ssl证书有效期', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (24, 17, '2024-09-14', '袁聪', '小程序（阿里云+微信）', '添加：岷江水务项目的ssl证书有效期', '添加：岷江水务项目的ssl证书有效期', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (25, 18, '2024-09-23', '袁聪', '小程序（阿里云+微信）', '更新：停车项目的ssl证书有效期', '更新：停车项目的ssl证书有效期', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (26, 19, '2024-10-22', '王小龙', '小程序（阿里云+微信）', '更新：充电宝项目的ssl证书有效期', '更新：充电宝项目的ssl证书有效期', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (27, 20, '2024-11-25', '王小龙', '小程序（阿里云+微信）', '更新：世纪-正式会议系统ssl证书有效期', '更新：世纪-正式会议系统ssl证书有效期', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (28, 21, '2024-11-29', '王小龙', '小程序（阿里云+微信）', '更新：MJSW ssl证书有效期', '更新：MJSW ssl证书有效期', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (29, 22, '2024-12-11', '王小龙', '应用系统台账表', '更新：经科信云安全服务', '更新：经科信云安全服务', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (30, 23, '2024-12-11', '王小龙', '小程序（阿里云+微信）', '添加：岷江水务小程序微信认证', '添加：岷江水务小程序微信认证', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (31, 24, '2024-12-11', '王小龙', '小程序（阿里云+微信）', '添加：短信资源包', '添加：短信资源包', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (32, 25, '2024-12-11', '王小龙', '小程序（阿里云+微信）', '更新：华泽停车项目ssl证书有效期', '更新：华泽停车项目ssl证书有效期', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (33, 26, '2024-12-11', '王小龙', '经信局（都江堰市工业企业信息化综合服务平台）', '添加：到期续费清单三', '添加：到期续费清单三', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (34, 27, '2024-12-11', '王小龙', '经信局（平台云安全资源清单）', '添加：到期续费清单二', '添加：到期续费清单二', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (35, 28, '2024-12-11', '王小龙', '天一泽世纪-研发测试环境（代码库）', '添加：到期续费清单二', '添加：到期续费清单二', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (36, 29, '2024-12-12', '王小龙', '世纪纵辰-OA综合管理系统', '添加：OA正式环境配置清单', '添加：OA正式环境配置清单', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (37, 30, '2024-12-12', '王小龙', '兴市集团-岷水建筑安装工程有限公司招投标官网', '更新：招投标官网配置清单', '更新：招投标官网配置清单', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (38, 31, '2024-12-12', '王小龙', '兴市集团-智慧公务用车车辆管理系统', '更新：公务用车系统配置清单', '更新：公务用车系统配置清单', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (39, 32, '2025-01-06', '杨伟', '文旅集团-都江堰百伦西联新系统', '添加：文旅集团-都江堰百伦西联新系统配置清单', '更新：文旅集团-都江堰百伦西联新系统配置清单', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (40, 33, '2025-02-05', '周柏光', '文旅集团-都江堰百伦西联新系统', '更新：文旅集团-都江堰百伦西联新系统配置清单', '更新：文旅集团-都江堰百伦西联新系统配置清单', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (41, 34, '2025-02-07', '周柏光', '经信局（都江堰市工业企业信息化综合服务平台）', '添加：到期续费清单四', '添加：到期续费清单四', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (42, 35, '2025-02-17', '周柏光', '天一泽世纪-研发测试环境（代码库）', '添加：到期续费清单三', '添加：到期续费清单三', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (43, 36, '2025-02-21', '周柏光', '世纪纵辰-OA综合管理系统', '添加：OA正式环境配置清单', '添加：OA正式环境配置清单', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (44, 37, '2025-02-24', '周柏光', '华泽数智（都来停-都经城市服务平台）', '添加：到期续费清单三', '添加：到期续费清单三', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (45, 38, '2025-03-03', '周柏光', '文旅集团-都江堰百伦西联新系统', '添加：到期续费清单一', '添加：到期续费清单一', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (46, 39, '2025-03-18', '周柏光', '天一泽世纪-研发测试环境（代码库）', '添加：到期续费清单四', '添加：到期续费清单四', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (47, 40, '2025-03-18', '周柏光', '公务用车系统系统云', '添加：到期续费清单一', '添加：到期续费清单一', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (48, 41, '2025-03-18', '杨洪', '域名到期时间', '添加: 域名到期时间', '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (49, 42, '2025-03-18', '杨洪', '小程序（阿里云+微信）', '更新:小程序（阿里云+微信）', '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (50, 43, '2025-03-26', '周柏光', '华泽数智（都来停-都经城市服务平台）', '添加：到期续费清单四', '添加：到期续费清单四', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (51, 44, '2025-04-07', '杨洪', '域名到期时间', '添加: 域名到期时间', '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (52, 45, '2025-04-14', '周柏光', '天一泽世纪-研发测试环境（代码库）', '添加：到期续费清单五', '添加：到期续费清单五', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (53, 46, '2025-04-14', '周柏光', '天一泽研发测试环境（运行库）云资源配置清单', '添加：到期续费清单二', '添加：到期续费清单二', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (54, 47, '2025-04-14', '周柏光', '兴市集团-智慧公务用车车辆管理系统', '添加：到期续费清单二', '添加：到期续费清单二', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (55, 48, '2025-05-12', '周柏光', '天一泽世纪-研发测试环境（代码库）', '添加：到期续费清单六', '添加：到期续费清单六', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (56, 49, '2025-05-12', '周柏光', '天一泽研发测试环境（运行库）云资源配置清单', '添加：到期续费清单三', '添加：到期续费清单三', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (57, 50, '2025-05-12', '周柏光', '兴市集团-智慧公务用车车辆管理系统', '添加：到期续费清单三', '添加：到期续费清单三', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (58, 52, '2025-04-10', '杨洪', '域名到期时间', '添加: 域名到期时间', '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (59, 53, '2025-05-07', '杨洪', '域名到期时间', '添加: 域名到期时间', '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (60, 54, '2025-05-08', '杨洪', '添加 数产生产应用系统台账表', '添加: 数产生产应用系统台账表', '添加：数产生产应用系统台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (61, 55, '2025-05-16', '杨洪', '添加 数产生产服务器台账表', '添加: 数产生产服务器台账表', '添加：数产生产服务器台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (62, 56, '2025-05-16', '杨洪', '添加 数产测试服务器台账表', '添加: 数产测试服务器台账表', '添加：数产测试服务器台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (63, 57, '2025-05-16', '杨洪', '更新: 应用系统台账表', '更新: 应用系统台账表', '修改：应用系统台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (64, 58, '2025-05-20', '周柏光', '天翼云nginx1服务器和nginx2服务器-云资源配置清单', '添加: nginx1服务器和nginx2服务器', 'nginx1服务器和nginx2服务器-云资源配置清单一', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (65, 59, '2025-05-20', '杨洪', '更新: 应用系统台账表', '更新: 应用系统台账表', '更新: 应用系统台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (66, 60, '2025-05-20', '杨洪', '更新: 域名到期时间', '更新: 域名到期时间', '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (67, 61, '2025-05-27', '杨洪', '更新: 域名到期时间', '更新: 域名到期时间', '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (68, 62, '2025-05-30', '杨洪', '更新:添加服务器', '更新:添加服务器', '应用台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (69, 63, '2025-06-11', '杨洪', '更新: 域名到期时间', '更新: 域名到期时间', '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (70, 64, '2025-06-11', '杨洪', '更新 数产测试服务器台账表', '更新: 数产测试服务器台账表', '更新：数产测试服务器台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (71, 65, '2025-06-11', '杨洪', '更新 数产生产服务器台账表', '更新: 数产生产服务器台账表', '更新：数产生产服务器台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (72, 66, '2025-06-12', '周柏光', '更新-世纪-OA分布式测试环境1', '更新-到期续费清单四', '世纪-OA分布式测试环境1', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (73, 67, '2025-06-12', '周柏光', '更新-公务用车系统正式环境', '更新-公务用车系统正式环境', '公务用车系统系统云', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (74, 68, '2025-06-12', '周柏光', '天一泽世纪-研发测试环境（代码库）', '添加：到期续费清单七', '添加：到期续费清单七', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (75, 69, '2025-06-12', '周柏光', '天一泽研发测试环境（运行库）云资源配置清单', '添加：到期续费清单四', '添加：到期续费清单四', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (76, 70, '2025-06-18', '杨洪', '更新: 域名到期时间', '更新: 域名到期时间', '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (77, 71, '2025-06-25', '杨洪', '更新: 域名到期时间', '更新: 域名到期时间', '更新：域名有效期（为负数的未更新）', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (78, 72, '2025-07-11', '周柏光', '天翼云nginx1服务器和nginx2服务器-云资源配置清单', '添加: nginx1服务器和nginx2服务器', 'nginx1服务器和nginx2服务器-云资源配置清单二', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (79, 73, '2025-07-11', '周柏光', '天一泽世纪-研发测试环境（代码库）', '添加：到期续费清单八', '添加：到期续费清单八', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (80, 74, '2025-07-11', '周柏光', '天一泽研发测试环境（运行库）云资源配置清单', '添加：到期续费清单五', '添加：到期续费清单五', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (81, 75, '2024-07-11', '杨洪', '应用系统台账表', '添加：世纪纵辰阿里云东软新能源短信AK-SK', '添加：世纪纵辰阿里云账号密码', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (82, 76, '2024-07-30', '周柏光', '华泽数智（都来停-都经城市服务平台）', '添加：到期续费清单五', '添加：到期续费清单五', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (83, 77, '2025-08-26', '周柏光', '天一泽世纪-研发测试环境（代码库）', '添加：到期续费清单九', '添加：到期续费清单九', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (84, 78, '2025-08-26', '周柏光', '天一泽研发测试环境（运行库）云资源配置清单', '添加：到期续费清单六', '添加：到期续费清单六', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (85, 79, '2025-08-26', '周柏光', '天翼云nginx1服务器和nginx2服务器-云资源配置清单', '添加: nginx1服务器和nginx2服务器', 'nginx1服务器和nginx2服务器-云资源配置清单三', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (86, 80, '2025-08-26', '周柏光', '更新-世纪-OA分布式测试环境3', 'OA3环境扩容-到期续费清单五', '世纪-OA分布式测试环境3', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (87, 81, '2025-08-26', '周柏光', '更新-世纪-OA分布式2和3', 'OA2和OA3环境-到期续费清单六', '世纪-OA2和OA3分布式环境', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (88, 82, '2025-11-20', '吴祥生', '世纪研发发测试环境（运行库）', '添加：到期续费清清单十', '添加：到期续费清清单十', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (89, 83, '2025-11-20', '吴祥生', 'nginx1服务器', '添加：到期续费清清单十', '添加：到期续费清清单十', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (90, 84, '2025-11-20', '吴祥生', 'nginx2服务器', '添加：到期续费清清单十', '添加：到期续费清清单十', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (91, 85, '2025-11-20', '吴祥生', '世纪研发测试环境（代码库）', '添加：到期续费清清单十', '添加：到期续费清清单十', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (92, 86, '2025-12-09', '吴祥生', '应用系统台账表', '更新海生天翼云账户', '修改：应用系统台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (93, 87, '2025-12-09', '吴祥生', '数产测试服务器台账表', '更新：数产测试服务器密码', '更新：数产测试服务器台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (94, 88, '2025-12-11', '吴祥生', '数产生产服务器台账', '更新：数产生产服务器密码', '更新：数产生产服务器密码', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (95, 89, '2025-12-11', '吴祥生', '添加水电集团-安全风险智能管控表', '添加水电集团-安全风险智能管控表', '添加水电集团-安全风险智能管控表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (96, 90, '2025-12-26', '吴祥生', '重做数产生产环境、测试环境台账表', '重做数产生产环境、测试环境台账表', '重做数产生产环境、测试环境台账表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (97, 91, '2026-01-13', '吴祥生', '新增web账户表', '新增web账户表', '新增web账户表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (98, 92, '2026-02-04', '吴祥生', '新增智慧环保生产表', '新增智慧环保生产表', '新增智慧环保生产表', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (99, 93, '2026-03-09', '吴祥生', '智慧环保表更新堡垒机密码、服务器root密码', '智慧环保表更新堡垒机密码、服务器root密码', '智慧环保表更新堡垒机密码、服务器root密码', '2026-04-01 15:57:32', '2026-04-01 15:57:32');
INSERT INTO `change_records` VALUES (100, 94, '2026-03-31', '吴祥生', '数产生产环境台账表新增数据中台服务器资源', '数产生产环境台账表新增数据中台服务器资源', '数产生产环境台账表新增数据中台服务器资源', '2026-04-01 15:57:32', '2026-04-01 15:57:32');

-- ----------------------------
-- Table structure for credentials
-- ----------------------------
DROP TABLE IF EXISTS `credentials`;
CREATE TABLE `credentials`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `credential_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `access_key_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'AccessKey ID',
  `access_key_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'AccessKey Secret',
  `is_active` tinyint NULL DEFAULT 1 COMMENT '是否启用 0:禁用 1:启用',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '账户描述',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `account_name`(`credential_name` ASC) USING BTREE,
  INDEX `idx_account_name`(`credential_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '阿里云账户配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of credentials
-- ----------------------------
INSERT INTO `credentials` VALUES (1, '阿里云-个人账户', 'LTAI5tEGSRqYEe8RBWZmGgC7', 'gAAAAABp0noIIBxlSo6M3Yt9eGPm8k9v8TI25mic1tLlbQ3_KdET0aULFA5smVIzcx1uKS21XrrX3nJvmAfYK7GH-JGULoUmkKflY5zhHFvb7ONTvzI9uUo=', 1, '', '2026-04-02 04:40:10', '2026-04-05 15:04:40');
INSERT INTO `credentials` VALUES (2, '阿里云-世纪纵辰-全权限AK-SK', 'LTAI5tBLWe73Zpkd1V2frciN', 'gAAAAABp0noBmPX2MQDGpQcMMRpIJKz4H26A5E5dCdV0bu2mM0sHFfdw7k-KsXGDdVhEXcuENl82ci_wS5140aIDETaCfQeplG6lDdccXkUr64Z-6jjHBlY=', 1, '', '2026-04-02 04:40:29', '2026-04-05 15:04:33');
INSERT INTO `credentials` VALUES (3, '阿里云-华泽数智-域名与证书AK-SK', 'LTAI5tSMU18RhVQgQA97cQ5X', 'gAAAAABp0nn8804dfQb6hm9cLFvn5K85jHN3LGXvo10MJtfhkwY8-wsAxRVOLRPEG4FKjkz3QMDcMr1pLdBD_sJ3x5oyXeAjh2dExI_W1CVWvNhtqLnGOjQ=', 1, '', '2026-04-02 05:37:42', '2026-04-05 15:04:28');
INSERT INTO `credentials` VALUES (4, '阿里云-华泽数智-城市服务平台AK-SK', 'LTAI5tGgDzdSkWW44wAwpSDB', 'gAAAAABp0nn2ttPErRHOTWy1b_1mrmZRBD4jYedyVtt_i_M7U9cazbcakZb9CnISxgTJ_LK66OnQYUL8dsNY4xrRCiYg49_woEgLwEqBEcuzeolyhDpcvlU=', 1, '', '2026-04-03 09:34:12', '2026-04-05 15:04:22');
INSERT INTO `credentials` VALUES (5, '阿里云-华泽数智-东软新能源短信AK-SK', 'LTAI5t87JAJbw51vpcmh4PXq', 'gAAAAABp0nnxBKmy7hFh2UiOh6-SI_L91qRHtgHy2-NyVDIgu9qImYFFIh-EGHQ2f7y5sn-UokenDH2Dxtd-IJvicaydZF33pcoJ4B3LjmIeG9SKXmnyzuk=', 1, '', '2026-04-03 09:35:59', '2026-04-05 15:04:17');
INSERT INTO `credentials` VALUES (6, '阿里云-华泽数智-parking_sms-AK-SK', 'LTAI5t7W2hQMCYNqwjDe3Rju', 'gAAAAABp0nnpqZavpbVTLXkb9rwVU1tv7CHgcHgYJqDKAfshyE6z4V76VY8gXR2M1bjSQU7WYYFWNqQ2LM_kkYv67Q-awNalXgI35-Bntr3WQq97pHsF-P8=', 1, '', '2026-04-03 09:38:27', '2026-04-05 15:04:09');

-- ----------------------------
-- Table structure for dict_env_types
-- ----------------------------
DROP TABLE IF EXISTS `dict_env_types`;
CREATE TABLE `dict_env_types`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '环境类型名称',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序号',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE,
  INDEX `idx_sort_order`(`sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 55 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '环境类型字典表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dict_env_types
-- ----------------------------
INSERT INTO `dict_env_types` VALUES (1, '测试', 1, '2026-04-01 16:32:52');
INSERT INTO `dict_env_types` VALUES (2, '生产', 2, '2026-04-01 16:32:52');

-- ----------------------------
-- Table structure for dict_platforms
-- ----------------------------
DROP TABLE IF EXISTS `dict_platforms`;
CREATE TABLE `dict_platforms`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '平台名称',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序号',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE,
  INDEX `idx_sort_order`(`sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 57 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '平台字典表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dict_platforms
-- ----------------------------
INSERT INTO `dict_platforms` VALUES (1, '都江堰数产私有云', 4, '2026-04-02 12:47:03');
INSERT INTO `dict_platforms` VALUES (2, '四川水电政务云', 3, '2026-04-02 12:56:43');
INSERT INTO `dict_platforms` VALUES (3, '天翼云', 2, '2026-04-03 00:07:26');
INSERT INTO `dict_platforms` VALUES (4, '阿里云', 0, '2026-04-03 09:55:02');
INSERT INTO `dict_platforms` VALUES (5, '腾讯云', 1, '2026-04-03 09:55:14');

-- ----------------------------
-- Table structure for dict_project_statuses
-- ----------------------------
DROP TABLE IF EXISTS `dict_project_statuses`;
CREATE TABLE `dict_project_statuses`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目状态名称',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序号',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE,
  INDEX `idx_sort_order`(`sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目状态字典表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dict_project_statuses
-- ----------------------------
INSERT INTO `dict_project_statuses` VALUES (1, '运行中', 1, '2026-04-05 14:40:44');
INSERT INTO `dict_project_statuses` VALUES (2, '已下线', 2, '2026-04-05 14:40:44');
INSERT INTO `dict_project_statuses` VALUES (3, '规划中', 3, '2026-04-05 14:40:44');

-- ----------------------------
-- Table structure for dict_service_categories
-- ----------------------------
DROP TABLE IF EXISTS `dict_service_categories`;
CREATE TABLE `dict_service_categories`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '服务分类名称',
  `sort_order` int NULL DEFAULT 0 COMMENT '排序号',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE,
  INDEX `idx_sort_order`(`sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '服务分类字典表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dict_service_categories
-- ----------------------------
INSERT INTO `dict_service_categories` VALUES (1, '关系型数据库', 1, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (2, 'NoSQL数据库', 2, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (3, '分布式缓存', 3, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (4, '消息队列', 4, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (5, '搜索引擎', 5, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (6, '数据平台与大数据', 6, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (7, '计算服务', 7, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (8, '存储服务', 8, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (9, '网络服务', 9, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (10, 'API网关与服务网格', 10, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (11, '微服务框架与运行时', 11, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (12, '服务发现与配置中心', 12, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (13, '前端与用户体验服务', 13, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (14, '日志、监控与可观测性', 14, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (15, '安全与身份认证', 15, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (16, '容器编排', 16, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (17, 'CI/CD流水线', 17, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (18, '任务调度与工作流', 18, '2026-04-05 17:15:36');
INSERT INTO `dict_service_categories` VALUES (19, '团队协作与项目管理', 19, '2026-04-10 03:05:42');
INSERT INTO `dict_service_categories` VALUES (20, '堡垒机', 20, '2026-04-10 03:23:31');
INSERT INTO `dict_service_categories` VALUES (21, '可视化工具', 21, '2026-04-10 06:42:38');
INSERT INTO `dict_service_categories` VALUES (22, '流计算', 22, '2026-04-10 06:42:38');

-- ----------------------------
-- Table structure for domains
-- ----------------------------
DROP TABLE IF EXISTS `domains`;
CREATE TABLE `domains`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `domain_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '域名',
  `registrar` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '注册商',
  `registration_date` date NULL DEFAULT NULL COMMENT '注册日期',
  `expire_date` date NULL DEFAULT NULL COMMENT '到期日期',
  `owner` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '持有者',
  `dns_servers` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'DNS服务器',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '正常' COMMENT '状态',
  `source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'manual' COMMENT '来源 manual/aliyun',
  `aliyun_account_id` int NULL DEFAULT NULL COMMENT '来源阿里云账户ID',
  `cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '费用',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `project_id` int NULL DEFAULT NULL COMMENT '所属项目ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `domain_name`(`domain_name` ASC) USING BTREE,
  INDEX `idx_domain_name`(`domain_name` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '域名管理表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of domains
-- ----------------------------
INSERT INTO `domains` VALUES (9, 'cdhzsz.com', '', '2023-05-18', '2026-05-18', '', '{\'DnsList\': [\'dns29.hichina.com\', \'dns30.hichina.com\']}', '3', 'aliyun', 3, NULL, NULL, '2026-04-02 11:30:00', '2026-04-02 11:30:00', NULL);
INSERT INTO `domains` VALUES (10, 'pepsikey.online', '', '2022-03-14', '2032-03-15', '', '{\'DnsList\': [\'dns3.hichina.com\', \'dns4.hichina.com\']}', '3', 'aliyun', 1, NULL, NULL, '2026-04-02 11:30:03', '2026-04-02 11:30:03', NULL);
INSERT INTO `domains` VALUES (15, 'msjszbpt.com', '', '2025-01-13', '2027-01-13', '', '{\'DnsList\': [\'dns23.hichina.com\', \'dns24.hichina.com\']}', '3', 'aliyun', 2, NULL, NULL, '2026-04-03 06:44:06', '2026-04-05 16:43:47', NULL);
INSERT INTO `domains` VALUES (16, 'sjzctg.com', '', '2024-08-19', '2026-08-19', '', '{\'DnsList\': [\'dns3.hichina.com\', \'dns4.hichina.com\']}', '3', 'aliyun', 2, NULL, NULL, '2026-04-03 06:44:06', '2026-04-07 07:57:41', 7);
INSERT INTO `domains` VALUES (18, 'sjzcgroup.com', '', '2024-08-19', '2026-08-19', '', '{\'DnsList\': [\'dns3.hichina.com\', \'dns4.hichina.com\']}', '3', 'aliyun', 2, NULL, NULL, '2026-04-07 07:57:04', '2026-04-07 07:57:04', NULL);
INSERT INTO `domains` VALUES (19, 'huazsz.com', '', '2023-05-18', '2026-05-18', '', '{\'DnsList\': [\'dns7.hichina.com\', \'dns8.hichina.com\']}', '3', 'aliyun', 3, NULL, NULL, '2026-04-07 07:57:22', '2026-04-07 07:57:22', NULL);

-- ----------------------------
-- Table structure for operation_logs
-- ----------------------------
DROP TABLE IF EXISTS `operation_logs`;
CREATE TABLE `operation_logs`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NULL DEFAULT NULL COMMENT '操作用户ID',
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作用户名',
  `module` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作模块: 服务器/服务/应用/域名/证书/用户等',
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型: create/update/delete/login等',
  `target_id` int NULL DEFAULT NULL COMMENT '操作对象ID',
  `target_name` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作对象名称',
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '操作详情(JSON)',
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作IP',
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '浏览器User-Agent',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_module`(`module` ASC) USING BTREE,
  INDEX `idx_action`(`action` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 716 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_logs
-- ----------------------------
INSERT INTO `operation_logs` VALUES (202, 30, 'admin', '证书管理', 'update', 14, 'openclaw.pepsikey.online', '{\"updated_fields\": [\"domain\", \"project_name\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 06:36:01');
INSERT INTO `operation_logs` VALUES (203, 30, 'admin', '阿里云账户', 'update', 3, '华泽数智', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 06:36:17');
INSERT INTO `operation_logs` VALUES (204, 30, 'admin', '阿里云账户', 'update', 2, '世纪纵辰', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 06:36:21');
INSERT INTO `operation_logs` VALUES (205, 30, 'admin', '域名管理', 'delete', 13, 'sjzcgroup.com', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 06:37:54');
INSERT INTO `operation_logs` VALUES (206, 30, 'admin', '服务器管理', 'delete', 55, 'q', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 06:40:22');
INSERT INTO `operation_logs` VALUES (207, 30, 'admin', '域名管理', 'delete', 14, 'sjzcgroup.com', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 06:43:57');
INSERT INTO `operation_logs` VALUES (208, 30, 'admin', '域名管理', 'delete', 12, 'sjzctg.com', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 06:43:59');
INSERT INTO `operation_logs` VALUES (209, 30, 'admin', '域名管理', 'delete', 11, 'msjszbpt.com', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 06:44:01');
INSERT INTO `operation_logs` VALUES (210, 30, 'admin', '证书管理', 'update', 28, 'web.huazsz.com', '{\"updated_fields\": [\"domain\", \"project_name\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 06:44:33');
INSERT INTO `operation_logs` VALUES (211, 30, 'admin', '阿里云账户', 'update', 1, '个人账户', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 06:44:43');
INSERT INTO `operation_logs` VALUES (212, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 08:49:34');
INSERT INTO `operation_logs` VALUES (213, 30, 'admin', '数据导出', 'export', NULL, '运维数据Excel', '{\"filename\": \"运维数据导出_2026-04-03.xlsx\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 08:49:36');
INSERT INTO `operation_logs` VALUES (214, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:16:19');
INSERT INTO `operation_logs` VALUES (215, 30, 'admin', '应用系统', 'create', 62, '天翼云官网', '{\"company\": \"成都海生科技有限公司\", \"access_url\": \"https://www.ctyun.cn/h5/activity/2022/index\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:19:30');
INSERT INTO `operation_logs` VALUES (216, 30, 'admin', '应用系统', 'create', 63, '天翼云官网', '{\"company\": \"四川世纪纵辰科技有限责任公司\", \"access_url\": \"https://www.ctyun.cn/h5/activity/2022/index\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:20:23');
INSERT INTO `operation_logs` VALUES (217, 30, 'admin', '阿里云账户', 'update', 1, '个人账户', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:29:40');
INSERT INTO `operation_logs` VALUES (218, 30, 'admin', '阿里云账户', 'update', 1, '个人账户', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:29:46');
INSERT INTO `operation_logs` VALUES (219, 30, 'admin', '阿里云账户', 'update', 3, '华泽数智', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:30:10');
INSERT INTO `operation_logs` VALUES (220, 30, 'admin', '阿里云账户', 'update', 2, '世纪纵辰', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:30:18');
INSERT INTO `operation_logs` VALUES (221, 30, 'admin', '阿里云账户', 'update', 3, '华泽数智', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:30:22');
INSERT INTO `operation_logs` VALUES (222, 30, 'admin', '应用系统', 'create', 64, '阿里云官网', '{\"company\": \"成都华泽数智信息技术有限公司\", \"access_url\": \"https://account.aliyun.com/login/login.htm?spm\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:31:40');
INSERT INTO `operation_logs` VALUES (223, 30, 'admin', '阿里云账户', 'create', 4, '华泽数智-城市服务平台AK', '{\"description\": \"\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:34:13');
INSERT INTO `operation_logs` VALUES (224, 30, 'admin', '阿里云账户', 'update', 3, '华泽数智-域名与证书AK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:34:49');
INSERT INTO `operation_logs` VALUES (225, 30, 'admin', '阿里云账户', 'update', 2, '世纪纵辰-全权限AK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:35:11');
INSERT INTO `operation_logs` VALUES (226, 30, 'admin', '阿里云账户', 'create', 5, '华泽数智-东软新能源短信AK-SK', '{\"description\": \"\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:36:00');
INSERT INTO `operation_logs` VALUES (227, 30, 'admin', '阿里云账户', 'update', 1, '个人账户', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:36:07');
INSERT INTO `operation_logs` VALUES (228, 30, 'admin', '阿里云账户', 'update', 4, '华泽数智-城市服务平台AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:36:21');
INSERT INTO `operation_logs` VALUES (229, 30, 'admin', '阿里云账户', 'update', 3, '华泽数智-域名与证书AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:36:31');
INSERT INTO `operation_logs` VALUES (230, 30, 'admin', '阿里云账户', 'update', 2, '世纪纵辰-全权限AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:36:37');
INSERT INTO `operation_logs` VALUES (231, 30, 'admin', '阿里云账户', 'update', 4, '华泽数智-城市服务平台AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:36:41');
INSERT INTO `operation_logs` VALUES (232, 30, 'admin', '阿里云账户', 'update', 3, '华泽数智-域名与证书AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:36:44');
INSERT INTO `operation_logs` VALUES (233, 30, 'admin', '阿里云账户', 'update', 2, '世纪纵辰-全权限AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:36:47');
INSERT INTO `operation_logs` VALUES (234, 30, 'admin', '阿里云账户', 'create', 6, '华泽数智-parking_sms-AK-SK', '{\"description\": \"\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:38:27');
INSERT INTO `operation_logs` VALUES (235, 30, 'admin', '应用系统', 'create', 65, '阿里云官网', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"https://account.aliyun.com/login/login.htm?spm\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:39:29');
INSERT INTO `operation_logs` VALUES (236, 30, 'admin', '应用系统', 'update', 62, '天翼云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:40:11');
INSERT INTO `operation_logs` VALUES (237, 30, 'admin', '应用系统', 'update', 63, '天翼云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:40:34');
INSERT INTO `operation_logs` VALUES (238, 30, 'admin', '应用系统', 'update', 63, '天翼云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:41:00');
INSERT INTO `operation_logs` VALUES (239, 30, 'admin', '应用系统', 'update', 62, '天翼云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:41:04');
INSERT INTO `operation_logs` VALUES (240, 30, 'admin', '应用系统', 'update', 63, '天翼云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:41:16');
INSERT INTO `operation_logs` VALUES (241, 30, 'admin', '应用系统', 'update', 64, '阿里云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:41:42');
INSERT INTO `operation_logs` VALUES (242, 30, 'admin', '应用系统', 'update', 65, '阿里云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:42:06');
INSERT INTO `operation_logs` VALUES (243, 30, 'admin', '应用系统', 'update', 62, '天翼云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:42:21');
INSERT INTO `operation_logs` VALUES (244, 30, 'admin', '应用系统', 'create', 66, '阿里云官网', '{\"company\": \"成都天宇新创智能科技有限公司\", \"access_url\": \"https://account.aliyun.com/login/login.htm?spm\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:43:20');
INSERT INTO `operation_logs` VALUES (245, 30, 'admin', '应用系统', 'create', 67, '阿里云官网', '{\"company\": \"成都海生科技有限公司\", \"access_url\": \"https://account.aliyun.com/login/login.htm?spm\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:44:08');
INSERT INTO `operation_logs` VALUES (246, 30, 'admin', '应用系统', 'update', 67, '阿里云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:44:25');
INSERT INTO `operation_logs` VALUES (247, 30, 'admin', '应用系统', 'create', 68, '阿里云官网', '{\"company\": \"四川世纪纵辰实业有限公司成都分公司\", \"access_url\": \"https://account.aliyun.com/login/login.htm?spm\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:45:33');
INSERT INTO `operation_logs` VALUES (248, 30, 'admin', '服务器管理', 'create', 56, 'djcsfw01', '{\"env_type\": \"生产\", \"inner_ip\": \"192.168.0.128\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 09:58:47');
INSERT INTO `operation_logs` VALUES (249, 30, 'admin', '证书管理', 'delete', 28, 'web.huazsz.com', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 10:02:43');
INSERT INTO `operation_logs` VALUES (250, 30, 'admin', '证书管理', 'delete', 14, 'openclaw.pepsikey.online', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 10:04:40');
INSERT INTO `operation_logs` VALUES (251, 30, 'admin', '证书管理', 'sync', 1, '个人账户', '{\"synced\": 1, \"updated\": 2, \"skipped\": 0, \"downloaded\": 1, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 13:45:43');
INSERT INTO `operation_logs` VALUES (252, 30, 'admin', '证书管理', 'sync', 2, '世纪纵辰-全权限AK-SK', '{\"synced\": 0, \"updated\": 6, \"skipped\": 0, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 13:46:46');
INSERT INTO `operation_logs` VALUES (253, 30, 'admin', '证书管理', 'sync', 1, '个人账户', '{\"synced\": 0, \"updated\": 0, \"skipped\": 3, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 13:48:08');
INSERT INTO `operation_logs` VALUES (254, 30, 'admin', '证书管理', 'sync', 1, '个人账户', '{\"synced\": 0, \"updated\": 0, \"skipped\": 3, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 13:55:04');
INSERT INTO `operation_logs` VALUES (255, 30, 'admin', '用户认证', 'login_failed', 30, 'admin', '{\"reason\": \"密码错误\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:02:27');
INSERT INTO `operation_logs` VALUES (256, 30, 'admin', '用户认证', 'login_failed', 30, 'admin', '{\"reason\": \"密码错误\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:02:34');
INSERT INTO `operation_logs` VALUES (257, 30, 'admin', '用户认证', 'login_failed', 30, 'admin', '{\"reason\": \"密码错误\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:02:42');
INSERT INTO `operation_logs` VALUES (258, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:03:42');
INSERT INTO `operation_logs` VALUES (259, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:04:35');
INSERT INTO `operation_logs` VALUES (260, 30, 'admin', '证书管理', 'sync', 2, '世纪纵辰-全权限AK-SK', '{\"synced\": 0, \"updated\": 0, \"skipped\": 6, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:08:49');
INSERT INTO `operation_logs` VALUES (261, 30, 'admin', '证书管理', 'sync', 3, '华泽数智-域名与证书AK-SK', '{\"synced\": 1, \"updated\": 1, \"skipped\": 0, \"downloaded\": 1, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:09:06');
INSERT INTO `operation_logs` VALUES (262, 30, 'admin', '服务器管理', 'update', 56, 'city-01', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:20:22');
INSERT INTO `operation_logs` VALUES (263, 30, 'admin', '服务器管理', 'create', 57, 'city-02', '{\"env_type\": \"生产\", \"inner_ip\": \"192.168.0.63\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:20:57');
INSERT INTO `operation_logs` VALUES (264, 30, 'admin', '服务器管理', 'create', 58, 'city-03', '{\"env_type\": \"测试\", \"inner_ip\": \"192.168.0.146\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:21:54');
INSERT INTO `operation_logs` VALUES (265, 30, 'admin', '服务器管理', 'update', 56, 'city-01', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:22:05');
INSERT INTO `operation_logs` VALUES (266, 30, 'admin', '服务器管理', 'update', 58, 'city-03', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:22:08');
INSERT INTO `operation_logs` VALUES (267, 30, 'admin', '服务器管理', 'update', 57, 'city-02', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:22:11');
INSERT INTO `operation_logs` VALUES (268, 30, 'admin', '服务器管理', 'create', 59, 'city-04', '{\"env_type\": \"生产\", \"inner_ip\": \"192.168.0.98\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:24:13');
INSERT INTO `operation_logs` VALUES (269, 30, 'admin', '服务器管理', 'update', 59, 'city-04', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:24:20');
INSERT INTO `operation_logs` VALUES (270, 30, 'admin', '服务器管理', 'create', 60, 'city-05', '{\"env_type\": \"生产\", \"inner_ip\": \"192.168.0.230\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:24:54');
INSERT INTO `operation_logs` VALUES (271, 30, 'admin', '服务器管理', 'update', 60, 'city-05', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:24:58');
INSERT INTO `operation_logs` VALUES (272, 30, 'admin', '服务器管理', 'create', 61, 'city-06', '{\"env_type\": \"生产\", \"inner_ip\": \"192.168.0.86\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:25:35');
INSERT INTO `operation_logs` VALUES (273, 30, 'admin', '服务器管理', 'update', 61, 'city-06', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:25:40');
INSERT INTO `operation_logs` VALUES (274, 30, 'admin', '服务器管理', 'update', 58, 'city-03', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:26:01');
INSERT INTO `operation_logs` VALUES (275, 30, 'admin', '服务器管理', 'create', 62, 'city-07', '{\"env_type\": \"生产\", \"inner_ip\": \"192.168.0.58\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:26:57');
INSERT INTO `operation_logs` VALUES (276, 30, 'admin', '服务器管理', 'update', 62, 'city-07', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:27:03');
INSERT INTO `operation_logs` VALUES (277, 30, 'admin', '服务器管理', 'update', 56, 'city-01', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:27:36');
INSERT INTO `operation_logs` VALUES (278, 30, 'admin', '服务器管理', 'update', 57, 'city-02', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:28:07');
INSERT INTO `operation_logs` VALUES (279, 30, 'admin', '服务器管理', 'update', 57, 'city-02', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:28:46');
INSERT INTO `operation_logs` VALUES (280, 30, 'admin', '服务器管理', 'update', 56, 'city-01', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:29:28');
INSERT INTO `operation_logs` VALUES (281, 30, 'admin', '服务器管理', 'update', 58, 'city-03', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:30:01');
INSERT INTO `operation_logs` VALUES (282, 30, 'admin', '服务器管理', 'update', 59, 'city-04', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:30:33');
INSERT INTO `operation_logs` VALUES (283, 30, 'admin', '服务器管理', 'update', 60, 'city-05', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:31:05');
INSERT INTO `operation_logs` VALUES (284, 30, 'admin', '服务器管理', 'update', 61, 'city-06', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:32:14');
INSERT INTO `operation_logs` VALUES (285, 30, 'admin', '服务器管理', 'update', 62, 'city-07', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:32:37');
INSERT INTO `operation_logs` VALUES (286, 30, 'admin', '服务器管理', 'create', 63, 'nginx', '{\"env_type\": \"生产\", \"inner_ip\": \"192.168.0.21\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:35:07');
INSERT INTO `operation_logs` VALUES (287, 30, 'admin', '证书管理', 'deploy', 29, 'openclaw.pepsikey.online', '{\"ssh_user\": \"root\", \"remote_path\": \"/tmp\", \"server_ip\": \"203.56.169.31\", \"ssh_port\": 22, \"verify_success\": true, \"errors\": null}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:35:48');
INSERT INTO `operation_logs` VALUES (288, 30, 'admin', '证书管理', 'deploy', 22, 'djymjsw.djymjsw.com', '{\"ssh_user\": \"root\", \"remote_path\": \"/tmp\", \"server_ip\": \"203.56.169.31\", \"ssh_port\": 22, \"verify_success\": true, \"errors\": null}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 14:39:38');
INSERT INTO `operation_logs` VALUES (289, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 15:35:51');
INSERT INTO `operation_logs` VALUES (290, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 15:36:47');
INSERT INTO `operation_logs` VALUES (291, 30, 'admin', '服务器管理', 'update', 63, 'nginx', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 15:49:44');
INSERT INTO `operation_logs` VALUES (292, 30, 'admin', '证书管理', 'deploy', 30, 'web.huazsz.com', '{\"ssh_user\": \"root\", \"remote_path\": \"/data/nginx-data/ssl\", \"server_ip\": \"203.56.169.31\", \"ssh_port\": 22, \"verify_success\": true, \"errors\": null}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-03 15:51:23');
INSERT INTO `operation_logs` VALUES (293, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.105', 'Mozilla/5.0 (iPhone; CPU iPhone OS 26_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) EdgiOS/146.0.3856.77 Version/26.0 Mobile/15E148 Safari/604.1', '2026-04-03 18:24:49');
INSERT INTO `operation_logs` VALUES (294, NULL, 'wxs', '用户认证', 'login_failed', NULL, 'wxs', '{\"reason\": \"用户不存在\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-04 00:27:48');
INSERT INTO `operation_logs` VALUES (295, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-04 00:27:51');
INSERT INTO `operation_logs` VALUES (296, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 00:44:59');
INSERT INTO `operation_logs` VALUES (297, 30, 'admin', '数据导出', 'export', NULL, '运维数据Excel', '{\"filename\": \"运维数据导出_2026-04-05.xlsx\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 00:57:13');
INSERT INTO `operation_logs` VALUES (298, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 01:08:02');
INSERT INTO `operation_logs` VALUES (299, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 01:08:22');
INSERT INTO `operation_logs` VALUES (300, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 01:23:00');
INSERT INTO `operation_logs` VALUES (301, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 01:34:00');
INSERT INTO `operation_logs` VALUES (302, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 01:36:11');
INSERT INTO `operation_logs` VALUES (303, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 01:37:35');
INSERT INTO `operation_logs` VALUES (304, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 01:38:25');
INSERT INTO `operation_logs` VALUES (305, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 01:42:26');
INSERT INTO `operation_logs` VALUES (306, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 01:58:26');
INSERT INTO `operation_logs` VALUES (307, 30, 'admin', '用户认证', 'login_failed', 30, 'admin', '{\"reason\": \"密码错误\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '2026-04-05 02:00:37');
INSERT INTO `operation_logs` VALUES (308, 30, 'admin', '用户认证', 'login_failed', 30, 'admin', '{\"reason\": \"密码错误\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '2026-04-05 02:00:48');
INSERT INTO `operation_logs` VALUES (309, 30, 'admin', '用户认证', 'login_failed', 30, 'admin', '{\"reason\": \"密码错误\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '2026-04-05 02:00:54');
INSERT INTO `operation_logs` VALUES (310, 30, 'admin', '用户认证', 'login_failed', 30, 'admin', '{\"reason\": \"密码错误\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '2026-04-05 02:01:00');
INSERT INTO `operation_logs` VALUES (311, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 02:01:09');
INSERT INTO `operation_logs` VALUES (312, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '2026-04-05 02:01:15');
INSERT INTO `operation_logs` VALUES (313, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 02:02:50');
INSERT INTO `operation_logs` VALUES (314, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 02:05:43');
INSERT INTO `operation_logs` VALUES (315, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 02:06:50');
INSERT INTO `operation_logs` VALUES (316, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 02:07:55');
INSERT INTO `operation_logs` VALUES (317, 30, 'admin', '服务管理', 'create', 3, 'test', '{\"category\": \"数据库\", \"version\": \"\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 02:08:17');
INSERT INTO `operation_logs` VALUES (318, 30, 'admin', '服务管理', 'delete', 3, 'test', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 02:08:33');
INSERT INTO `operation_logs` VALUES (319, 30, 'admin', '服务器管理', 'create', 64, '1', '{\"env_type\": \"测试\", \"inner_ip\": \"1.1.1.1\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 12:19:15');
INSERT INTO `operation_logs` VALUES (320, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 12:32:44');
INSERT INTO `operation_logs` VALUES (321, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 12:33:03');
INSERT INTO `operation_logs` VALUES (322, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 12:44:57');
INSERT INTO `operation_logs` VALUES (323, 30, 'admin', '服务器管理', 'delete', 64, '1', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:09:41');
INSERT INTO `operation_logs` VALUES (324, 30, 'admin', '证书管理', 'sync', 3, '华泽数智-域名与证书AK-SK', '{\"synced\": 2, \"updated\": 0, \"skipped\": 0, \"downloaded\": 2, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:43:24');
INSERT INTO `operation_logs` VALUES (325, 30, 'admin', '证书管理', 'sync', 1, '个人账户', '{\"synced\": 3, \"updated\": 0, \"skipped\": 0, \"downloaded\": 3, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:43:25');
INSERT INTO `operation_logs` VALUES (326, 30, 'admin', '证书管理', 'sync', 2, '世纪纵辰-全权限AK-SK', '{\"synced\": 6, \"updated\": 0, \"skipped\": 0, \"downloaded\": 6, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:43:26');
INSERT INTO `operation_logs` VALUES (327, 30, 'admin', '证书管理', 'sync', 3, '华泽数智-域名与证书AK-SK', '{\"synced\": 2, \"updated\": 0, \"skipped\": 0, \"downloaded\": 2, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:47:50');
INSERT INTO `operation_logs` VALUES (328, 30, 'admin', '证书管理', 'sync', 1, '个人账户', '{\"synced\": 3, \"updated\": 0, \"skipped\": 0, \"downloaded\": 3, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:47:51');
INSERT INTO `operation_logs` VALUES (329, 30, 'admin', '证书管理', 'sync', 2, '世纪纵辰-全权限AK-SK', '{\"synced\": 6, \"updated\": 0, \"skipped\": 0, \"downloaded\": 6, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:47:51');
INSERT INTO `operation_logs` VALUES (330, 30, 'admin', '项目管理', 'create', 1, '智慧环保', '{\"owner\": \"\", \"status\": \"运行中\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:55:36');
INSERT INTO `operation_logs` VALUES (331, 30, 'admin', '域名管理', 'update', 17, 'sjzcgroup.com', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:55:50');
INSERT INTO `operation_logs` VALUES (332, 30, 'admin', '证书管理', 'update', 46, 'web.huazsz.com', '{\"updated_fields\": [\"domain\", \"project_name\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"linked_project_name\", \"notify_status\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:56:06');
INSERT INTO `operation_logs` VALUES (333, 30, 'admin', '证书管理', 'update', 46, 'web.huazsz.com', '{\"updated_fields\": [\"domain\", \"project_name\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"linked_project_name\", \"notify_status\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:56:20');
INSERT INTO `operation_logs` VALUES (334, 30, 'admin', '证书管理', 'update', 46, 'web.huazsz.com', '{\"updated_fields\": [\"domain\", \"project_name\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"linked_project_name\", \"notify_status\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:56:25');
INSERT INTO `operation_logs` VALUES (335, 30, 'admin', '证书管理', 'update', 42, 'opm.pepsikey.online', '{\"updated_fields\": [\"domain\", \"project_name\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"linked_project_name\", \"notify_status\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 14:56:36');
INSERT INTO `operation_logs` VALUES (336, 30, 'admin', '服务管理', 'create', 4, 'mysql', '{\"category\": \"数据库\", \"version\": \"8.0\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:00:40');
INSERT INTO `operation_logs` VALUES (337, 30, 'admin', '凭证', 'update', 6, '阿里云-华泽数智-parking_sms-AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:04:10');
INSERT INTO `operation_logs` VALUES (338, 30, 'admin', '凭证', 'update', 5, '阿里云-华泽数智-东软新能源短信AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:04:18');
INSERT INTO `operation_logs` VALUES (339, 30, 'admin', '凭证', 'update', 4, '阿里云-华泽数智-城市服务平台AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:04:22');
INSERT INTO `operation_logs` VALUES (340, 30, 'admin', '凭证', 'update', 3, '阿里云-华泽数智-域名与证书AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:04:29');
INSERT INTO `operation_logs` VALUES (341, 30, 'admin', '凭证', 'update', 2, '阿里云-世纪纵辰-全权限AK-SK', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:04:34');
INSERT INTO `operation_logs` VALUES (342, 30, 'admin', '凭证', 'update', 1, '阿里云-个人账户', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:04:40');
INSERT INTO `operation_logs` VALUES (343, 30, 'admin', '证书管理', 'update', 46, 'web.huazsz.com', '{\"updated_fields\": [\"domain\", \"project_name\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"linked_project_name\", \"notify_status\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:06:54');
INSERT INTO `operation_logs` VALUES (344, 30, 'admin', '证书管理', 'sync', 3, '阿里云-华泽数智-域名与证书AK-SK', '{\"synced\": 2, \"updated\": 0, \"skipped\": 0, \"downloaded\": 2, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:07:21');
INSERT INTO `operation_logs` VALUES (345, 30, 'admin', '证书管理', 'sync', 1, '阿里云-个人账户', '{\"synced\": 3, \"updated\": 0, \"skipped\": 0, \"downloaded\": 3, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:07:21');
INSERT INTO `operation_logs` VALUES (346, 30, 'admin', '证书管理', 'sync', 2, '阿里云-世纪纵辰-全权限AK-SK', '{\"synced\": 6, \"updated\": 0, \"skipped\": 0, \"downloaded\": 6, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:07:22');
INSERT INTO `operation_logs` VALUES (347, 30, 'admin', '证书管理', 'update', 53, 'opm.pepsikey.online', '{\"updated_fields\": [\"domain\", \"project_name\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"linked_project_name\", \"notify_status\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:07:41');
INSERT INTO `operation_logs` VALUES (348, 30, 'admin', '证书管理', 'update', 58, 'web.huazsz.com', '{\"updated_fields\": [\"domain\", \"project_name\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"linked_project_name\", \"notify_status\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:09:01');
INSERT INTO `operation_logs` VALUES (349, 30, 'admin', '证书管理', 'sync', 1, '阿里云-个人账户', '{\"synced\": 0, \"updated\": 0, \"skipped\": 3, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:12:27');
INSERT INTO `operation_logs` VALUES (350, 30, 'admin', '域名管理', 'update', 17, 'sjzcgroup.com', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:17:41');
INSERT INTO `operation_logs` VALUES (351, 30, 'admin', '项目管理', 'update', 1, '智慧环保', '{\"action\": \"关联服务器\", \"server_ids\": [56], \"added_count\": 1}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:18:14');
INSERT INTO `operation_logs` VALUES (352, 30, 'admin', '账号', 'update', 62, '天翼云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:23:49');
INSERT INTO `operation_logs` VALUES (353, 30, 'admin', '域名管理', 'update', 16, 'sjzctg.com', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:25:24');
INSERT INTO `operation_logs` VALUES (354, 30, 'admin', '证书管理', 'update', 60, 'openclaw.pepsikey.online', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:25:29');
INSERT INTO `operation_logs` VALUES (355, 30, 'admin', '项目管理', 'create', 2, '四川水电', '{\"owner\": \"\", \"status\": \"运行中\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:25:41');
INSERT INTO `operation_logs` VALUES (356, 30, 'admin', '域名管理', 'update', 15, 'msjszbpt.com', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:25:48');
INSERT INTO `operation_logs` VALUES (357, 30, 'admin', '证书管理', 'update', 54, 'cdb.huazsz.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:25:53');
INSERT INTO `operation_logs` VALUES (358, 30, 'admin', '证书管理', 'update', 59, 'hytest.sjzctg.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:25:59');
INSERT INTO `operation_logs` VALUES (359, 30, 'admin', '账号', 'update', 65, '阿里云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:26:09');
INSERT INTO `operation_logs` VALUES (360, 30, 'admin', '服务管理', 'create', 5, 'Redis', '{\"category\": \"缓存\", \"version\": \"6\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:26:43');
INSERT INTO `operation_logs` VALUES (361, 30, 'admin', '项目管理', 'update', 2, '四川水电', '{\"action\": \"关联服务器\", \"server_ids\": [57], \"added_count\": 1}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 15:27:31');
INSERT INTO `operation_logs` VALUES (362, 30, 'admin', '项目管理', 'create', 3, '数据中台', '{\"owner\": \"\", \"status\": \"运行中\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:10:41');
INSERT INTO `operation_logs` VALUES (363, 30, 'admin', '项目管理', 'update', 3, '数据中台', '{\"action\": \"关联服务器\", \"server_ids\": [58, 59], \"added_count\": 2}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:10:53');
INSERT INTO `operation_logs` VALUES (364, 30, 'admin', '证书管理', 'sync', 3, '阿里云-华泽数智-域名与证书AK-SK', '{\"synced\": 0, \"updated\": 0, \"skipped\": 2, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:27:57');
INSERT INTO `operation_logs` VALUES (365, 30, 'admin', '证书管理', 'sync', 1, '阿里云-个人账户', '{\"synced\": 0, \"updated\": 0, \"skipped\": 3, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:27:57');
INSERT INTO `operation_logs` VALUES (366, 30, 'admin', '证书管理', 'sync', 2, '阿里云-世纪纵辰-全权限AK-SK', '{\"synced\": 0, \"updated\": 0, \"skipped\": 6, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:27:57');
INSERT INTO `operation_logs` VALUES (367, 30, 'admin', '项目管理', 'update', 3, '数据中台', '{\"action\": \"取消关联服务器\", \"server_id\": 58}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:39:52');
INSERT INTO `operation_logs` VALUES (368, 30, 'admin', '项目管理', 'update', 3, '数据中台', '{\"action\": \"取消关联服务器\", \"server_id\": 59}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:39:53');
INSERT INTO `operation_logs` VALUES (369, 30, 'admin', '项目管理', 'update', 2, '四川水电', '{\"action\": \"取消关联服务器\", \"server_id\": 57}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:39:57');
INSERT INTO `operation_logs` VALUES (370, 30, 'admin', '服务管理', 'delete', 4, 'mysql', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:40:04');
INSERT INTO `operation_logs` VALUES (371, 30, 'admin', '服务管理', 'delete', 5, 'Redis', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:40:05');
INSERT INTO `operation_logs` VALUES (372, 30, 'admin', '项目管理', 'update', 1, '智慧环保', '{\"action\": \"取消关联服务器\", \"server_id\": 56}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:40:11');
INSERT INTO `operation_logs` VALUES (373, 30, 'admin', '账号', 'update', 62, '天翼云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:40:27');
INSERT INTO `operation_logs` VALUES (374, 30, 'admin', '账号', 'update', 62, '天翼云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 16:40:33');
INSERT INTO `operation_logs` VALUES (375, 30, 'admin', '服务器管理', 'delete', 65, 'centos8.5', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 17:03:10');
INSERT INTO `operation_logs` VALUES (376, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 17:16:27');
INSERT INTO `operation_logs` VALUES (377, 30, 'admin', '服务管理', 'create', 6, 'nginx', '{\"category\": \"网络服务\", \"version\": \"1.27.5\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 17:29:02');
INSERT INTO `operation_logs` VALUES (378, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.101', 'Mozilla/5.0 (iPhone; CPU iPhone OS 26_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) EdgiOS/146.0.3856.77 Version/26.0 Mobile/15E148 Safari/604.1', '2026-04-05 18:17:10');
INSERT INTO `operation_logs` VALUES (379, 30, 'admin', '服务器管理', 'update', 68, 'm7', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:28:33');
INSERT INTO `operation_logs` VALUES (380, 30, 'admin', '服务器管理', 'update', 69, 'm8', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:29:01');
INSERT INTO `operation_logs` VALUES (381, 30, 'admin', '服务器管理', 'update', 70, 'm1', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:29:31');
INSERT INTO `operation_logs` VALUES (382, 30, 'admin', '服务器管理', 'update', 71, 'm0', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:32:05');
INSERT INTO `operation_logs` VALUES (383, 30, 'admin', '服务器管理', 'update', 72, 'm9', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:33:26');
INSERT INTO `operation_logs` VALUES (384, 30, 'admin', '服务器管理', 'update', 73, 'm2', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:33:48');
INSERT INTO `operation_logs` VALUES (385, 30, 'admin', '服务器管理', 'update', 74, 'm3', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:34:02');
INSERT INTO `operation_logs` VALUES (386, 30, 'admin', '服务器管理', 'update', 75, 'm6', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:34:15');
INSERT INTO `operation_logs` VALUES (387, 30, 'admin', '服务器管理', 'update', 76, 'm4', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:34:22');
INSERT INTO `operation_logs` VALUES (388, 30, 'admin', '服务器管理', 'update', 77, 'm5', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:34:51');
INSERT INTO `operation_logs` VALUES (389, 30, 'admin', '服务器管理', 'update', 78, 'node1', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:35:06');
INSERT INTO `operation_logs` VALUES (390, 30, 'admin', '项目管理', 'create', 4, '岷江水务招投标', '{\"owner\": \"\", \"status\": \"运行中\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-05 18:36:36');
INSERT INTO `operation_logs` VALUES (391, 30, 'admin', '证书管理', 'sync', 3, '阿里云-华泽数智-域名与证书AK-SK', '{\"synced\": 0, \"updated\": 0, \"skipped\": 2, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:38:22');
INSERT INTO `operation_logs` VALUES (392, 30, 'admin', '证书管理', 'sync', 1, '阿里云-个人账户', '{\"synced\": 0, \"updated\": 0, \"skipped\": 3, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:38:22');
INSERT INTO `operation_logs` VALUES (393, 30, 'admin', '证书管理', 'sync', 2, '阿里云-世纪纵辰-全权限AK-SK', '{\"synced\": 0, \"updated\": 0, \"skipped\": 6, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:38:22');
INSERT INTO `operation_logs` VALUES (394, 30, 'admin', '证书管理', 'sync', 2, '阿里云-世纪纵辰-全权限AK-SK', '{\"synced\": 0, \"updated\": 0, \"skipped\": 6, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:38:27');
INSERT INTO `operation_logs` VALUES (395, 30, 'admin', '证书管理', 'sync', 3, '阿里云-华泽数智-域名与证书AK-SK', '{\"synced\": 0, \"updated\": 0, \"skipped\": 2, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:38:27');
INSERT INTO `operation_logs` VALUES (396, 30, 'admin', '证书管理', 'sync', 1, '阿里云-个人账户', '{\"synced\": 0, \"updated\": 0, \"skipped\": 3, \"downloaded\": 0, \"download_failed\": 0}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:38:27');
INSERT INTO `operation_logs` VALUES (397, 30, 'admin', '账号', 'update', 65, '阿里云官网', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:38:42');
INSERT INTO `operation_logs` VALUES (398, 30, 'admin', '项目管理', 'create', 5, '都江堰市工业企业信息化综合服务平台', '{\"owner\": \"\", \"status\": \"运行中\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:41:37');
INSERT INTO `operation_logs` VALUES (399, 30, 'admin', '项目管理', 'update', 5, '都江堰市工业企业信息化综合服务平台', '{\"action\": \"关联服务器\", \"server_ids\": [68, 69], \"added_count\": 2}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:42:20');
INSERT INTO `operation_logs` VALUES (400, 30, 'admin', '项目管理', 'update', 4, '岷水建设招标平台', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:42:49');
INSERT INTO `operation_logs` VALUES (401, 30, 'admin', '项目管理', 'update', 4, '岷水建设招标平台', '{\"action\": \"关联服务器\", \"server_ids\": [70, 71, 72], \"added_count\": 3}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:43:08');
INSERT INTO `operation_logs` VALUES (402, 30, 'admin', '项目管理', 'create', 6, '智慧车辆管理系统', '{\"owner\": \"\", \"status\": \"运行中\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:43:20');
INSERT INTO `operation_logs` VALUES (403, 30, 'admin', '项目管理', 'update', 6, '智慧车辆管理系统', '{\"action\": \"关联服务器\", \"server_ids\": [73, 74], \"added_count\": 2}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:43:38');
INSERT INTO `operation_logs` VALUES (404, 30, 'admin', '项目管理', 'create', 7, 'OA综合管理系统', '{\"owner\": \"\", \"status\": \"运行中\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:44:03');
INSERT INTO `operation_logs` VALUES (405, 30, 'admin', '项目管理', 'update', 7, 'OA综合管理系统', '{\"action\": \"关联服务器\", \"server_ids\": [75, 76], \"added_count\": 2}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:44:20');
INSERT INTO `operation_logs` VALUES (406, 30, 'admin', '项目管理', 'update', 1, '智慧环保', '{\"action\": \"关联服务器\", \"server_ids\": [78, 77], \"added_count\": 2}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:44:44');
INSERT INTO `operation_logs` VALUES (407, 30, 'admin', '服务器管理', 'create', 79, 'sdc-data', '{\"env_type\": \"生产\", \"inner_ip\": \"172.24.17.38\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:48:00');
INSERT INTO `operation_logs` VALUES (408, 30, 'admin', '服务器管理', 'update', 79, 'sdc-data', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:48:35');
INSERT INTO `operation_logs` VALUES (409, 30, 'admin', '服务器管理', 'update', 79, 'sdc-data', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:48:44');
INSERT INTO `operation_logs` VALUES (410, 30, 'admin', '服务器管理', 'create', 80, 'sdc-app', '{\"env_type\": \"生产\", \"inner_ip\": \"172.24.1.53\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:49:56');
INSERT INTO `operation_logs` VALUES (411, 30, 'admin', '服务器管理', 'update', 79, 'sdc-data', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:50:07');
INSERT INTO `operation_logs` VALUES (412, 30, 'admin', '服务器管理', 'update', 80, 'sdc-app', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:50:47');
INSERT INTO `operation_logs` VALUES (413, 30, 'admin', '项目管理', 'create', 8, '灌小七城市生活服务平台', '{\"owner\": \"\", \"status\": \"运行中\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:51:25');
INSERT INTO `operation_logs` VALUES (414, 30, 'admin', '项目管理', 'update', 3, '世纪纵辰数据中台', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 03:52:11');
INSERT INTO `operation_logs` VALUES (415, 30, 'admin', '数据导出', 'export', NULL, '运维数据Excel', '{\"filename\": \"运维数据导出_2026-04-06.xlsx\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 04:12:05');
INSERT INTO `operation_logs` VALUES (416, 30, 'admin', '服务管理', 'update', 6, 'nginx', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 04:13:17');
INSERT INTO `operation_logs` VALUES (417, 30, 'admin', '服务管理', 'update', 6, 'nginx', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 04:13:47');
INSERT INTO `operation_logs` VALUES (418, 30, 'admin', '证书管理', 'update', 60, 'openclaw.pepsikey.online', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 05:03:21');
INSERT INTO `operation_logs` VALUES (419, 30, 'admin', '域名管理', 'update', 17, 'sjzcgroup.com', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 05:03:50');
INSERT INTO `operation_logs` VALUES (420, 30, 'admin', '项目管理', 'create', 9, 'CI/CD', '{\"owner\": \"\", \"status\": \"运行中\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 05:08:43');
INSERT INTO `operation_logs` VALUES (421, 30, 'admin', '服务器管理', 'create', 81, 'harbor', '{\"env_type\": \"生产\", \"inner_ip\": \"172.24.17.31\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 05:11:13');
INSERT INTO `operation_logs` VALUES (422, 30, 'admin', '服务器管理', 'update', 81, 'harbor', NULL, '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 05:11:48');
INSERT INTO `operation_logs` VALUES (423, 30, 'admin', '服务管理', 'create', 7, 'docker', '{\"category\": \"容器编排\", \"version\": \"26.1.4\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 05:57:14');
INSERT INTO `operation_logs` VALUES (424, 30, 'admin', '服务管理', 'create', 8, 'docker-compose', '{\"category\": \"容器编排\", \"version\": \"v2.39.2\"}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 05:58:14');
INSERT INTO `operation_logs` VALUES (425, 30, 'admin', '项目管理', 'update', 9, 'CI/CD', '{\"action\": \"关联服务器\", \"server_ids\": [63], \"added_count\": 1}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 05:58:53');
INSERT INTO `operation_logs` VALUES (426, 30, 'admin', '项目管理', 'update', 9, 'CI/CD', '{\"action\": \"取消关联服务器\", \"server_id\": 63}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 05:59:11');
INSERT INTO `operation_logs` VALUES (427, 30, 'admin', '项目管理', 'update', 9, 'CI/CD', '{\"action\": \"关联服务器\", \"server_ids\": [63], \"added_count\": 1}', '192.168.1.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-06 05:59:25');
INSERT INTO `operation_logs` VALUES (428, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.1.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 05:55:52');
INSERT INTO `operation_logs` VALUES (429, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 06:10:08');
INSERT INTO `operation_logs` VALUES (430, 30, 'admin', '服务器管理', 'update', 78, 'node1', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 06:13:41');
INSERT INTO `operation_logs` VALUES (431, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 06:13:54');
INSERT INTO `operation_logs` VALUES (432, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:32:56');
INSERT INTO `operation_logs` VALUES (433, 30, 'admin', '服务器管理', 'update', 79, 'sdc-data', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:36:32');
INSERT INTO `operation_logs` VALUES (434, 30, 'admin', '服务器管理', 'update', 79, 'sdc-data', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:37:00');
INSERT INTO `operation_logs` VALUES (435, 30, 'admin', '服务器管理', 'update', 79, 'sdc-data', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:37:05');
INSERT INTO `operation_logs` VALUES (436, 30, 'admin', '服务器管理', 'update', 77, 'm5', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:40:47');
INSERT INTO `operation_logs` VALUES (437, 30, 'admin', '服务器管理', 'update', 131, 'node-172-24-17-30', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:43:01');
INSERT INTO `operation_logs` VALUES (438, 30, 'admin', '服务器管理', 'update', 132, 'node-172-24-17-52', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:45:14');
INSERT INTO `operation_logs` VALUES (439, 30, 'admin', '服务器管理', 'update', 132, 'node-172-24-17-52', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:46:08');
INSERT INTO `operation_logs` VALUES (440, 30, 'admin', '服务器管理', 'update', 132, 'node-172-24-17-52', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:47:15');
INSERT INTO `operation_logs` VALUES (441, 30, 'admin', '项目管理', 'update', 9, 'CI/CD', '{\"action\": \"关联服务器\", \"server_ids\": [131], \"added_count\": 1}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:51:41');
INSERT INTO `operation_logs` VALUES (442, 30, 'admin', '服务器管理', 'create', 146, 'jenkins', '{\"env_type\": \"生产\", \"inner_ip\": \"172.24.17.31\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:55:09');
INSERT INTO `operation_logs` VALUES (443, 30, 'admin', '项目管理', 'update', 7, 'OA综合管理系统', '{\"action\": \"关联服务器\", \"server_ids\": [114, 115], \"added_count\": 2}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:55:38');
INSERT INTO `operation_logs` VALUES (444, 30, 'admin', '项目管理', 'update', 7, 'OA综合管理系统', '{\"action\": \"关联服务器\", \"server_ids\": [75, 76], \"added_count\": 2}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:55:55');
INSERT INTO `operation_logs` VALUES (445, 30, 'admin', '证书管理', 'sync', 2, '阿里云-世纪纵辰-全权限AK-SK', '{\"synced\": 0, \"updated\": 0, \"skipped\": 6, \"downloaded\": 0, \"download_failed\": 0}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:56:34');
INSERT INTO `operation_logs` VALUES (446, 30, 'admin', '域名管理', 'delete', 17, 'sjzcgroup.com', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:56:58');
INSERT INTO `operation_logs` VALUES (447, 30, 'admin', '域名管理', 'delete', 8, 'huazsz.com', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:57:15');
INSERT INTO `operation_logs` VALUES (448, 30, 'admin', '域名管理', 'update', 16, 'sjzctg.com', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 07:57:42');
INSERT INTO `operation_logs` VALUES (449, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 08:26:12');
INSERT INTO `operation_logs` VALUES (450, 30, 'admin', '项目管理', 'update', 1, '智慧环保', '{\"action\": \"关联服务器\", \"server_ids\": [78, 77], \"added_count\": 2}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 09:10:45');
INSERT INTO `operation_logs` VALUES (451, 30, 'admin', '服务器管理', 'update', 146, 'cicd-jenkins', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 09:19:10');
INSERT INTO `operation_logs` VALUES (452, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 09:52:39');
INSERT INTO `operation_logs` VALUES (453, 30, 'admin', '服务器管理', 'update', 132, 'zentao', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-07 09:53:21');
INSERT INTO `operation_logs` VALUES (454, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 01:28:38');
INSERT INTO `operation_logs` VALUES (455, 30, 'admin', '服务器管理', 'update', 146, 'cicd-jenkins', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 01:29:45');
INSERT INTO `operation_logs` VALUES (456, 30, 'admin', '服务器管理', 'update', 131, 'node-172-24-17-30', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 01:30:26');
INSERT INTO `operation_logs` VALUES (457, 30, 'admin', '服务器管理', 'update', 131, 'gitlab', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 01:30:47');
INSERT INTO `operation_logs` VALUES (458, 30, 'admin', '服务器管理', 'update', 146, 'cicd-jenkins', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 01:31:01');
INSERT INTO `operation_logs` VALUES (459, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 02:32:35');
INSERT INTO `operation_logs` VALUES (460, 30, 'admin', '项目管理', 'create', 10, '企业级团队协作与项目管理', '{\"owner\": \"\", \"status\": \"运行中\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 02:40:20');
INSERT INTO `operation_logs` VALUES (461, 30, 'admin', '项目管理', 'update', 10, '团队协作与项目管理', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 02:40:27');
INSERT INTO `operation_logs` VALUES (462, 30, 'admin', '项目管理', 'update', 10, '团队协作与项目管理', '{\"action\": \"关联服务器\", \"server_ids\": [132], \"added_count\": 1}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 02:40:39');
INSERT INTO `operation_logs` VALUES (463, 30, 'admin', '服务器管理', 'update', 130, 'cms2', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 02:44:54');
INSERT INTO `operation_logs` VALUES (464, 30, 'admin', '服务器管理', 'update', 130, 'cms2', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 02:45:44');
INSERT INTO `operation_logs` VALUES (465, 30, 'admin', '项目管理', 'update', 8, '灌小七城市生活服务平台', '{\"action\": \"关联服务器\", \"server_ids\": [120, 119, 118, 117], \"added_count\": 4}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 02:55:38');
INSERT INTO `operation_logs` VALUES (466, 30, 'admin', '服务器管理', 'update', 118, 'gxq19', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 02:57:42');
INSERT INTO `operation_logs` VALUES (467, 30, 'admin', '服务器管理', 'update', 120, 'gxq17', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 03:17:21');
INSERT INTO `operation_logs` VALUES (468, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 03:40:01');
INSERT INTO `operation_logs` VALUES (469, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36', '2026-04-08 03:42:29');
INSERT INTO `operation_logs` VALUES (470, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:00:26');
INSERT INTO `operation_logs` VALUES (471, 30, 'admin', '服务器管理', 'update', 130, 'cicd-jenkins-node', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:12:33');
INSERT INTO `operation_logs` VALUES (472, 30, 'admin', '服务器管理', 'update', 130, 'cicd-jenkins-node', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:12:49');
INSERT INTO `operation_logs` VALUES (473, 30, 'admin', '服务器管理', 'update', 129, 'cms3', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:12:58');
INSERT INTO `operation_logs` VALUES (474, 30, 'admin', '服务器管理', 'update', 128, 'cms4', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:13:05');
INSERT INTO `operation_logs` VALUES (475, 30, 'admin', '服务器管理', 'update', 127, 'cms5', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:13:13');
INSERT INTO `operation_logs` VALUES (476, 30, 'admin', '服务器管理', 'update', 126, 'car6', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:13:21');
INSERT INTO `operation_logs` VALUES (477, 30, 'admin', '服务器管理', 'update', 129, 'cms3', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:13:57');
INSERT INTO `operation_logs` VALUES (478, 30, 'admin', '服务器管理', 'update', 128, 'cms4', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:17:32');
INSERT INTO `operation_logs` VALUES (479, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36', '2026-04-08 05:23:06');
INSERT INTO `operation_logs` VALUES (480, 30, 'admin', '服务器管理', 'update', 127, 'cms5', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:26:02');
INSERT INTO `operation_logs` VALUES (481, 30, 'admin', '服务器管理', 'update', 126, 'car6', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:27:12');
INSERT INTO `operation_logs` VALUES (482, 30, 'admin', '服务器管理', 'update', 125, 'car7', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:29:04');
INSERT INTO `operation_logs` VALUES (483, 30, 'admin', '项目管理', 'update', 4, '岷水建设招标平台', '{\"action\": \"关联服务器\", \"server_ids\": [124, 123, 122], \"added_count\": 3}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:34:00');
INSERT INTO `operation_logs` VALUES (484, 30, 'admin', '服务器管理', 'update', 124, 'tender0', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:37:03');
INSERT INTO `operation_logs` VALUES (485, 30, 'admin', '服务器管理', 'update', 123, 'tender1', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:37:52');
INSERT INTO `operation_logs` VALUES (486, 30, 'admin', '服务器管理', 'update', 122, 'tender2', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 05:38:16');
INSERT INTO `operation_logs` VALUES (487, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 06:12:48');
INSERT INTO `operation_logs` VALUES (488, 30, 'admin', '项目管理', 'create', 11, '都经城市服务平台', '{\"owner\": \"\", \"status\": \"运行中\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 06:12:57');
INSERT INTO `operation_logs` VALUES (489, 30, 'admin', '项目管理', 'update', 11, '都经城市服务平台', '{\"action\": \"关联服务器\", \"server_ids\": [62, 61, 60, 59, 58, 57, 56], \"added_count\": 7}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 06:13:17');
INSERT INTO `operation_logs` VALUES (490, 30, 'admin', '服务器管理', 'update', 121, 'nexus', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 06:15:39');
INSERT INTO `operation_logs` VALUES (491, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 07:26:59');
INSERT INTO `operation_logs` VALUES (492, 30, 'admin', '服务器管理', 'update', 119, 'gxq18', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 07:27:25');
INSERT INTO `operation_logs` VALUES (493, 30, 'admin', '服务器管理', 'update', 117, 'gxq20', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 07:37:41');
INSERT INTO `operation_logs` VALUES (494, 30, 'admin', '服务器管理', 'update', 115, 'oaserver2', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 07:45:28');
INSERT INTO `operation_logs` VALUES (495, 30, 'admin', '服务器管理', 'update', 114, 'oaserver1', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 07:45:40');
INSERT INTO `operation_logs` VALUES (496, 30, 'admin', '服务器管理', 'update', 121, 'nexus', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 07:45:52');
INSERT INTO `operation_logs` VALUES (497, 30, 'admin', '服务器管理', 'update', 81, 'harbor', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 07:46:01');
INSERT INTO `operation_logs` VALUES (498, 30, 'admin', '服务器管理', 'update', 81, 'harbor', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 07:46:08');
INSERT INTO `operation_logs` VALUES (499, 30, 'admin', '服务器管理', 'update', 80, 'sdc-app', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 07:53:30');
INSERT INTO `operation_logs` VALUES (500, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 17:49:48');
INSERT INTO `operation_logs` VALUES (501, 30, 'admin', '证书管理', 'create', 64, 'hy.sjzctg.com', '{\"project_id\": 7, \"cert_type\": \"手动录入\"}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 17:51:09');
INSERT INTO `operation_logs` VALUES (502, 30, 'admin', '证书管理', 'update', 55, 'sdc.sjzctg.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 17:52:26');
INSERT INTO `operation_logs` VALUES (503, 30, 'admin', '证书管理', 'update', 56, 'h5.sjzctg.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 17:52:42');
INSERT INTO `operation_logs` VALUES (504, 30, 'admin', '证书管理', 'update', 59, 'hytest.sjzctg.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 17:52:52');
INSERT INTO `operation_logs` VALUES (505, 30, 'admin', '证书管理', 'update', 61, 'www.msjszbpt.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 17:53:06');
INSERT INTO `operation_logs` VALUES (506, 30, 'admin', '证书管理', 'update', 62, 'bm.msjszbpt.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 17:53:13');
INSERT INTO `operation_logs` VALUES (507, 30, 'admin', '服务器管理', 'update', 132, 'zentao', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 17:57:32');
INSERT INTO `operation_logs` VALUES (508, 30, 'admin', '服务器管理', 'delete', 146, 'cicd-jenkins', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 17:58:31');
INSERT INTO `operation_logs` VALUES (509, 30, 'admin', '服务器管理', 'update', 130, 'cicd-jenkins-master', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:01:37');
INSERT INTO `operation_logs` VALUES (510, 30, 'admin', '服务器管理', 'update', 130, 'cicd-jenkins-node', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:02:05');
INSERT INTO `operation_logs` VALUES (511, 30, 'admin', '服务器管理', 'update', 81, 'cicd-jenkins-harbor', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:02:48');
INSERT INTO `operation_logs` VALUES (512, 30, 'admin', '证书管理', 'create', 65, 'huazsz.com', '{\"project_id\": null, \"cert_type\": \"手动录入\"}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:14:53');
INSERT INTO `operation_logs` VALUES (513, 30, 'admin', '证书管理', 'update', 65, 'www.huazsz.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\", \"checking\"]}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:15:11');
INSERT INTO `operation_logs` VALUES (514, 30, 'admin', '证书管理', 'delete', 65, 'www.huazsz.com', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:15:30');
INSERT INTO `operation_logs` VALUES (515, 30, 'admin', '证书管理', 'update', 58, 'www.huazsz.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:15:39');
INSERT INTO `operation_logs` VALUES (516, 30, 'admin', '证书管理', 'update', 58, 'oss.huazsz.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\", \"checking\"]}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:15:53');
INSERT INTO `operation_logs` VALUES (517, 30, 'admin', '证书管理', 'delete', 64, 'hy.sjzctg.com', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:16:49');
INSERT INTO `operation_logs` VALUES (518, 30, 'admin', '证书管理', 'create', 66, 'hy.sjzctg.com', '{\"project_id\": 7, \"cert_type\": \"手动录入\"}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:17:01');
INSERT INTO `operation_logs` VALUES (519, 30, 'admin', '证书管理', 'upload', 67, 'web.huazsz.com', '{\"issuer\": \"Encryption Everywhere DV TLS CA - G2\", \"valid_days\": 89, \"remaining_days\": 4}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:19:11');
INSERT INTO `operation_logs` VALUES (520, 30, 'admin', '证书管理', 'delete', 67, 'web.huazsz.com', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:20:04');
INSERT INTO `operation_logs` VALUES (521, 30, 'admin', '证书管理', 'update', 58, 'web.huazsz.com', '{\"updated_fields\": [\"domain\", \"cert_type\", \"issuer\", \"cert_expire_time\", \"brand\", \"cost\", \"status\", \"project_id\", \"remark\", \"aliyun_account_id\", \"cert_file_path\", \"cert_generate_time\", \"cert_valid_days\", \"created_at\", \"has_cert_file\", \"id\", \"key_file_path\", \"last_check_time\", \"last_notify_time\", \"notify_status\", \"project_name\", \"remaining_days\", \"source\", \"updated_at\"]}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:20:16');
INSERT INTO `operation_logs` VALUES (522, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-08 18:51:51');
INSERT INTO `operation_logs` VALUES (523, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 02:46:34');
INSERT INTO `operation_logs` VALUES (524, 30, 'admin', '数据导出', 'export', NULL, '运维数据Excel', '{\"filename\": \"运维数据导出_2026-04-09.xlsx\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 03:40:13');
INSERT INTO `operation_logs` VALUES (525, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 03:47:13');
INSERT INTO `operation_logs` VALUES (526, 30, 'admin', '服务管理', 'create', 9, 'docker', '{\"category\": \"容器编排\", \"version\": \"26.1.4\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 03:47:30');
INSERT INTO `operation_logs` VALUES (527, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:39:11');
INSERT INTO `operation_logs` VALUES (528, 30, 'admin', '服务管理', 'create', 10, 'ubuntu-desktop', '{\"category\": \"前端与用户体验服务\", \"version\": \"31901\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:39:51');
INSERT INTO `operation_logs` VALUES (529, 30, 'admin', '服务管理', 'create', 11, 'harbor-jobservice', '{\"category\": \"容器编排\", \"version\": \"v2.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:40:56');
INSERT INTO `operation_logs` VALUES (530, 30, 'admin', '服务管理', 'create', 12, 'nginx-photon', '{\"category\": \"容器编排\", \"version\": \"v2.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:44:38');
INSERT INTO `operation_logs` VALUES (531, 30, 'admin', '服务管理', 'create', 13, 'harbor-core', '{\"category\": \"容器编排\", \"version\": \"v2.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:45:14');
INSERT INTO `operation_logs` VALUES (532, 30, 'admin', '服务管理', 'update', 12, 'nginx-photon', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:45:47');
INSERT INTO `operation_logs` VALUES (533, 30, 'admin', '服务管理', 'create', 14, 'harbor-db', '{\"category\": \"容器编排\", \"version\": \"v2.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:46:18');
INSERT INTO `operation_logs` VALUES (534, 30, 'admin', '服务管理', 'update', 14, 'harbor-db', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:46:35');
INSERT INTO `operation_logs` VALUES (535, 30, 'admin', '服务管理', 'create', 15, 'registry-photon', '{\"category\": \"容器编排\", \"version\": \"v2.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:46:59');
INSERT INTO `operation_logs` VALUES (536, 30, 'admin', '服务管理', 'create', 16, 'redis', '{\"category\": \"容器编排\", \"version\": \"v2.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:48:33');
INSERT INTO `operation_logs` VALUES (537, 30, 'admin', '服务管理', 'create', 17, 'harbor-portal', '{\"category\": \"容器编排\", \"version\": \"v2.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:49:03');
INSERT INTO `operation_logs` VALUES (538, 30, 'admin', '服务管理', 'create', 18, 'harbor-registryctl', '{\"category\": \"容器编排\", \"version\": \"v2.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:49:30');
INSERT INTO `operation_logs` VALUES (539, 30, 'admin', '服务管理', 'create', 19, 'harbor-log', '{\"category\": \"容器编排\", \"version\": \"v2.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:49:50');
INSERT INTO `operation_logs` VALUES (540, 30, 'admin', '服务管理', 'create', 20, 'jenkins', '{\"category\": \"CI/CD流水线\", \"version\": \"2.543\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:52:45');
INSERT INTO `operation_logs` VALUES (541, 30, 'admin', '服务管理', 'create', 21, 'node-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"v1.9.1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:53:32');
INSERT INTO `operation_logs` VALUES (542, 30, 'admin', '项目管理', 'create', 12, '监控', '{\"owner\": \"\", \"status\": \"运行中\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:54:19');
INSERT INTO `operation_logs` VALUES (543, 30, 'admin', '服务管理', 'update', 21, 'node-exporter', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:54:30');
INSERT INTO `operation_logs` VALUES (544, 30, 'admin', '服务管理', 'create', 22, 'cadvisor', '{\"category\": \"日志、监控与可观测性\", \"version\": \"v0.52.0\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:54:55');
INSERT INTO `operation_logs` VALUES (545, 30, 'admin', '服务管理', 'create', 23, 'ssh', '{\"category\": \"安全与身份认证\", \"version\": \"8.9p1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:57:08');
INSERT INTO `operation_logs` VALUES (546, 30, 'admin', '项目管理', 'delete', 12, '监控', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:57:23');
INSERT INTO `operation_logs` VALUES (547, 30, 'admin', '服务管理', 'update', 22, 'cadvisor', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:57:40');
INSERT INTO `operation_logs` VALUES (548, 30, 'admin', '服务管理', 'create', 24, 'docker-compose', '{\"category\": \"容器编排\", \"version\": \"v5.0.0\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 07:59:41');
INSERT INTO `operation_logs` VALUES (549, 30, 'admin', '服务管理', 'create', 25, 'ssh', '{\"category\": \"安全与身份认证\", \"version\": \"8.9p1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:16:44');
INSERT INTO `operation_logs` VALUES (550, 30, 'admin', '服务管理', 'create', 26, 'docker', '{\"category\": \"容器编排\", \"version\": \"29.1.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:19:33');
INSERT INTO `operation_logs` VALUES (551, 30, 'admin', '服务管理', 'create', 27, 'docker-compose', '{\"category\": \"容器编排\", \"version\": \"v5.0.0\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:19:52');
INSERT INTO `operation_logs` VALUES (552, 30, 'admin', '服务管理', 'create', 28, 'gitlab-ce', '{\"category\": \"CI/CD流水线\", \"version\": \"15.2.2-ce.0 \"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:21:00');
INSERT INTO `operation_logs` VALUES (553, 30, 'admin', '服务管理', 'create', 29, 'node-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"v1.9.1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:25:29');
INSERT INTO `operation_logs` VALUES (554, 30, 'admin', '服务管理', 'create', 30, 'cadvisor', '{\"category\": \"日志、监控与可观测性\", \"version\": \"v0.52.0\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:27:57');
INSERT INTO `operation_logs` VALUES (555, 30, 'admin', '服务管理', 'create', 31, 'docker', '{\"category\": \"容器编排\", \"version\": \"26.1.4\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:32:44');
INSERT INTO `operation_logs` VALUES (556, 30, 'admin', '服务管理', 'create', 32, 'docker-compose', '{\"category\": \"容器编排\", \"version\": \"v2.39.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:33:12');
INSERT INTO `operation_logs` VALUES (557, 30, 'admin', '服务管理', 'create', 33, 'nginx', '{\"category\": \"网络服务\", \"version\": \"1.20.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:34:43');
INSERT INTO `operation_logs` VALUES (558, 30, 'admin', '服务管理', 'create', 34, 'ssh', '{\"category\": \"安全与身份认证\", \"version\": \"7.4p1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:38:02');
INSERT INTO `operation_logs` VALUES (559, 30, 'admin', '服务管理', 'create', 35, 'asset', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:38:49');
INSERT INTO `operation_logs` VALUES (560, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:50:22');
INSERT INTO `operation_logs` VALUES (561, 30, 'admin', '服务管理', 'create', 36, 'bup', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:50:46');
INSERT INTO `operation_logs` VALUES (562, 30, 'admin', '服务管理', 'create', 37, 'camunda', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:51:16');
INSERT INTO `operation_logs` VALUES (563, 30, 'admin', '服务管理', 'create', 38, 'file', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:51:41');
INSERT INTO `operation_logs` VALUES (564, 30, 'admin', '服务管理', 'create', 39, 'gateway', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:52:06');
INSERT INTO `operation_logs` VALUES (565, 30, 'admin', '服务管理', 'create', 40, 'meeting', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:52:23');
INSERT INTO `operation_logs` VALUES (566, 30, 'admin', '服务管理', 'create', 41, 'oasystem', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:54:09');
INSERT INTO `operation_logs` VALUES (567, 30, 'admin', '服务管理', 'create', 42, 'oauth', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:55:14');
INSERT INTO `operation_logs` VALUES (568, 30, 'admin', '服务管理', 'create', 43, 'project', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 08:55:47');
INSERT INTO `operation_logs` VALUES (569, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 09:16:13');
INSERT INTO `operation_logs` VALUES (570, 30, 'admin', '服务管理', 'create', 44, 'node-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"v1.9.1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 09:28:21');
INSERT INTO `operation_logs` VALUES (571, 30, 'admin', '服务管理', 'create', 45, 'cadvisor', '{\"category\": \"日志、监控与可观测性\", \"version\": \"v0.52.0\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 09:32:33');
INSERT INTO `operation_logs` VALUES (572, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-09 09:54:57');
INSERT INTO `operation_logs` VALUES (573, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 01:13:54');
INSERT INTO `operation_logs` VALUES (574, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 02:16:29');
INSERT INTO `operation_logs` VALUES (575, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '2026-04-10 02:28:34');
INSERT INTO `operation_logs` VALUES (576, 30, 'admin', '数据导出', 'export', NULL, '运维数据Excel', '{\"filename\": \"运维数据导出_2026-04-10.xlsx\"}', '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '2026-04-10 02:45:46');
INSERT INTO `operation_logs` VALUES (577, 30, 'admin', '服务管理', 'create', 46, 'docker', '{\"category\": \"容器编排\", \"version\": \"26.1.4\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 02:56:22');
INSERT INTO `operation_logs` VALUES (578, 30, 'admin', '服务管理', 'create', 47, 'docker-compose', '{\"category\": \"容器编排\", \"version\": \"v2.39.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 02:56:37');
INSERT INTO `operation_logs` VALUES (579, 30, 'admin', '服务管理', 'create', 48, 'ssh', '{\"category\": \"安全与身份认证\", \"version\": \"7.4p1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 02:57:03');
INSERT INTO `operation_logs` VALUES (580, 30, 'admin', '服务管理', 'create', 49, 'elasticsearch', '{\"category\": \"NoSQL数据库\", \"version\": \"7.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 02:58:49');
INSERT INTO `operation_logs` VALUES (581, 30, 'admin', '服务管理', 'create', 50, 'mongo', '{\"category\": \"NoSQL数据库\", \"version\": \"7\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 02:59:12');
INSERT INTO `operation_logs` VALUES (582, 30, 'admin', '服务管理', 'create', 51, 'redis', '{\"category\": \"关系型数据库\", \"version\": \"6\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 02:59:48');
INSERT INTO `operation_logs` VALUES (583, 30, 'admin', '服务管理', 'create', 52, 'mysql', '{\"category\": \"关系型数据库\", \"version\": \"8.0.28\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:00:07');
INSERT INTO `operation_logs` VALUES (584, 30, 'admin', '服务管理', 'create', 53, 'minio', '{\"category\": \"存储服务\", \"version\": \"RELEASE.2024-09-09T16-59-28Z\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:00:34');
INSERT INTO `operation_logs` VALUES (585, 30, 'admin', '服务管理', 'create', 54, 'rabbitmq', '{\"category\": \"消息队列\", \"version\": \"4.2.0\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:01:22');
INSERT INTO `operation_logs` VALUES (586, 30, 'admin', '服务管理', 'create', 55, 'nacos', '{\"category\": \"服务发现与配置中心\", \"version\": \"v2.4.3\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:01:56');
INSERT INTO `operation_logs` VALUES (587, 30, 'admin', '服务管理', 'create', 56, 'grafana', '{\"category\": \"日志、监控与可观测性\", \"version\": \"12.2-ubuntu\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:02:26');
INSERT INTO `operation_logs` VALUES (588, 30, 'admin', '服务管理', 'create', 57, 'prometheus', '{\"category\": \"日志、监控与可观测性\", \"version\": \"v3.6.0\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:03:18');
INSERT INTO `operation_logs` VALUES (589, 30, 'admin', '服务管理', 'create', 58, 'node-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"v1.9.1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:03:43');
INSERT INTO `operation_logs` VALUES (590, 30, 'admin', '服务管理', 'create', 59, 'cadvisor', '{\"category\": \"日志、监控与可观测性\", \"version\": \"v0.52.0\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:04:02');
INSERT INTO `operation_logs` VALUES (591, 30, 'admin', '服务管理', 'create', 60, 'confluence', '{\"category\": \"团队协作与项目管理\", \"version\": \"8.5.5\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:06:29');
INSERT INTO `operation_logs` VALUES (592, 30, 'admin', '服务管理', 'create', 61, 'docker', '{\"category\": \"容器编排\", \"version\": \"26.1.4\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:07:17');
INSERT INTO `operation_logs` VALUES (593, 30, 'admin', '服务管理', 'create', 62, 'docker-compose', '{\"category\": \"容器编排\", \"version\": \"v2.11.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:07:36');
INSERT INTO `operation_logs` VALUES (594, 30, 'admin', '服务管理', 'create', 63, 'ssh', '{\"category\": \"安全与身份认证\", \"version\": \"7.4p1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:07:59');
INSERT INTO `operation_logs` VALUES (595, 30, 'admin', '服务管理', 'create', 64, 'harbor-jobservice', '{\"category\": \"CI/CD流水线\", \"version\": \"v2.8.2 \"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:08:33');
INSERT INTO `operation_logs` VALUES (596, 30, 'admin', '服务管理', 'create', 65, 'nginx-photon', '{\"category\": \"CI/CD流水线\", \"version\": \"v2.8.2 \"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:09:19');
INSERT INTO `operation_logs` VALUES (597, 30, 'admin', '服务管理', 'create', 66, 'harbor-core', '{\"category\": \"CI/CD流水线\", \"version\": \"v2.8.2 \"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:10:43');
INSERT INTO `operation_logs` VALUES (598, 30, 'admin', '服务管理', 'update', 65, 'nginx-photon', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:10:59');
INSERT INTO `operation_logs` VALUES (599, 30, 'admin', '服务管理', 'create', 67, 'registry-photon', '{\"category\": \"CI/CD流水线\", \"version\": \"v2.8.2 \"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:11:47');
INSERT INTO `operation_logs` VALUES (600, 30, 'admin', '服务管理', 'create', 68, 'harbor-db', '{\"category\": \"CI/CD流水线\", \"version\": \"v2.8.2 \"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:12:07');
INSERT INTO `operation_logs` VALUES (601, 30, 'admin', '服务管理', 'create', 69, 'harbor-registryctl', '{\"category\": \"CI/CD流水线\", \"version\": \"v2.8.2 \"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:12:34');
INSERT INTO `operation_logs` VALUES (602, 30, 'admin', '服务管理', 'update', 69, 'harbor-registryctl', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:12:45');
INSERT INTO `operation_logs` VALUES (603, 30, 'admin', '服务管理', 'create', 70, 'redis-photon', '{\"category\": \"CI/CD流水线\", \"version\": \"v2.8.2 \"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:13:08');
INSERT INTO `operation_logs` VALUES (604, 30, 'admin', '服务管理', 'create', 71, 'harbor-log', '{\"category\": \"CI/CD流水线\", \"version\": \"v2.8.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:13:37');
INSERT INTO `operation_logs` VALUES (605, 30, 'admin', '服务管理', 'create', 72, 'harbor-portal', '{\"category\": \"CI/CD流水线\", \"version\": \"v2.8.2 \"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:13:53');
INSERT INTO `operation_logs` VALUES (606, 30, 'admin', '服务管理', 'create', 73, 'jenkins', '{\"category\": \"CI/CD流水线\", \"version\": \"2.13.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:14:27');
INSERT INTO `operation_logs` VALUES (607, 30, 'admin', '服务管理', 'create', 74, 'nexus3', '{\"category\": \"CI/CD流水线\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:14:55');
INSERT INTO `operation_logs` VALUES (608, 30, 'admin', '服务管理', 'create', 75, 'redis', '{\"category\": \"关系型数据库\", \"version\": \"6.2.6\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:15:47');
INSERT INTO `operation_logs` VALUES (609, 30, 'admin', '服务管理', 'create', 76, 'redis-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:16:12');
INSERT INTO `operation_logs` VALUES (610, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:16:43');
INSERT INTO `operation_logs` VALUES (611, 30, 'admin', '服务管理', 'create', 77, 'node-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:16:59');
INSERT INTO `operation_logs` VALUES (612, 30, 'admin', '服务管理', 'create', 78, 'cadvisor', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:17:18');
INSERT INTO `operation_logs` VALUES (613, 30, 'admin', '服务管理', 'create', 79, 'docker', '{\"category\": \"容器编排\", \"version\": \"26.1.4\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:21:07');
INSERT INTO `operation_logs` VALUES (614, 30, 'admin', '服务管理', 'create', 80, 'docker-compose', '{\"category\": \"容器编排\", \"version\": \"v2.11.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:21:23');
INSERT INTO `operation_logs` VALUES (615, 30, 'admin', '服务管理', 'create', 81, 'ssh', '{\"category\": \"安全与身份认证\", \"version\": \"7.4p1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:21:51');
INSERT INTO `operation_logs` VALUES (616, 30, 'admin', '服务管理', 'create', 82, 'lion', '{\"category\": \"堡垒机\", \"version\": \"v3.10.12\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:24:31');
INSERT INTO `operation_logs` VALUES (617, 30, 'admin', '服务管理', 'create', 83, 'core-ce', '{\"category\": \"堡垒机\", \"version\": \"v3.10.12\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:24:53');
INSERT INTO `operation_logs` VALUES (618, 30, 'admin', '服务管理', 'create', 84, 'redis', '{\"category\": \"堡垒机\", \"version\": \"v3.10.12\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:25:43');
INSERT INTO `operation_logs` VALUES (619, 30, 'admin', '服务管理', 'create', 85, 'koko', '{\"category\": \"堡垒机\", \"version\": \"v3.10.12\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:26:09');
INSERT INTO `operation_logs` VALUES (620, 30, 'admin', '服务管理', 'create', 86, 'magnus', '{\"category\": \"堡垒机\", \"version\": \"v3.10.12\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:29:15');
INSERT INTO `operation_logs` VALUES (621, 30, 'admin', '服务管理', 'create', 87, 'kael', '{\"category\": \"堡垒机\", \"version\": \"v3.10.12\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:29:33');
INSERT INTO `operation_logs` VALUES (622, 30, 'admin', '服务管理', 'create', 88, 'chen', '{\"category\": \"堡垒机\", \"version\": \"v3.10.12\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:29:50');
INSERT INTO `operation_logs` VALUES (623, 30, 'admin', '服务管理', 'create', 89, 'web', '{\"category\": \"堡垒机\", \"version\": \"v3.10.12\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:30:28');
INSERT INTO `operation_logs` VALUES (624, 30, 'admin', '服务管理', 'create', 90, 'mariadb', '{\"category\": \"堡垒机\", \"version\": \"10.6\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:30:52');
INSERT INTO `operation_logs` VALUES (625, 30, 'admin', '服务管理', 'create', 91, 'nginx', '{\"category\": \"网络服务\", \"version\": \"1.27.4\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:31:29');
INSERT INTO `operation_logs` VALUES (626, 30, 'admin', '服务管理', 'create', 92, 'mysql', '{\"category\": \"关系型数据库\", \"version\": \"8.0.41\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:31:52');
INSERT INTO `operation_logs` VALUES (627, 30, 'admin', '服务管理', 'create', 93, 'prometheus', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:32:16');
INSERT INTO `operation_logs` VALUES (628, 30, 'admin', '服务管理', 'create', 94, 'syslog-ng', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:32:43');
INSERT INTO `operation_logs` VALUES (629, 30, 'admin', '服务管理', 'create', 95, 'blackbox-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:33:04');
INSERT INTO `operation_logs` VALUES (630, 30, 'admin', '服务管理', 'create', 96, 'prometheus-webhook-dingtalk', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:33:23');
INSERT INTO `operation_logs` VALUES (631, 30, 'admin', '服务管理', 'create', 97, 'node-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:33:40');
INSERT INTO `operation_logs` VALUES (632, 30, 'admin', '服务管理', 'create', 98, 'cadvisor', '{\"category\": \"安全与身份认证\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:34:00');
INSERT INTO `operation_logs` VALUES (633, 30, 'admin', '服务管理', 'create', 99, 'grafana', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:34:22');
INSERT INTO `operation_logs` VALUES (634, 30, 'admin', '服务管理', 'create', 100, 'snmp-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:34:42');
INSERT INTO `operation_logs` VALUES (635, 30, 'admin', '服务管理', 'create', 101, 'promtail', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:35:03');
INSERT INTO `operation_logs` VALUES (636, 30, 'admin', '服务管理', 'create', 102, 'loki', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:35:48');
INSERT INTO `operation_logs` VALUES (637, 30, 'admin', '服务管理', 'create', 103, 'docker', '{\"category\": \"容器编排\", \"version\": \"26.1.4\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:37:29');
INSERT INTO `operation_logs` VALUES (638, 30, 'admin', '服务管理', 'create', 104, 'docker-compose', '{\"category\": \"容器编排\", \"version\": \"v2.11.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:37:44');
INSERT INTO `operation_logs` VALUES (639, 30, 'admin', '服务管理', 'create', 105, 'ssh', '{\"category\": \"安全与身份认证\", \"version\": \"7.4p1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:38:06');
INSERT INTO `operation_logs` VALUES (640, 30, 'admin', '服务管理', 'create', 106, 'redis', '{\"category\": \"关系型数据库\", \"version\": \"7.4.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:38:45');
INSERT INTO `operation_logs` VALUES (641, 30, 'admin', '服务管理', 'create', 107, 'nginx-prometheus-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:39:27');
INSERT INTO `operation_logs` VALUES (642, 30, 'admin', '服务管理', 'create', 108, 'elasticsearch-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:39:46');
INSERT INTO `operation_logs` VALUES (643, 30, 'admin', '服务管理', 'create', 109, 'redis-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:40:04');
INSERT INTO `operation_logs` VALUES (644, 30, 'admin', '服务管理', 'create', 110, 'node-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:40:24');
INSERT INTO `operation_logs` VALUES (645, 30, 'admin', '服务管理', 'create', 111, 'cadvisor', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:40:37');
INSERT INTO `operation_logs` VALUES (646, 30, 'admin', '服务管理', 'create', 112, 'promtail', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:41:00');
INSERT INTO `operation_logs` VALUES (647, 30, 'admin', '服务管理', 'create', 113, 'nginx', '{\"category\": \"网络服务\", \"version\": \"1.18.0\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:41:59');
INSERT INTO `operation_logs` VALUES (648, 30, 'admin', '服务管理', 'create', 114, 'minio', '{\"category\": \"存储服务\", \"version\": \"RELEASE.2021-06-17T00-10-46Z\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:42:24');
INSERT INTO `operation_logs` VALUES (649, 30, 'admin', '服务管理', 'create', 115, 'elasticsearch', '{\"category\": \"NoSQL数据库\", \"version\": \"7.12.1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:42:51');
INSERT INTO `operation_logs` VALUES (650, 30, 'admin', '服务管理', 'update', 114, 'minio', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:43:02');
INSERT INTO `operation_logs` VALUES (651, 30, 'admin', '服务管理', 'create', 116, 'nacos', '{\"category\": \"服务发现与配置中心\", \"version\": \"1.4.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:43:31');
INSERT INTO `operation_logs` VALUES (652, 30, 'admin', '服务管理', 'create', 117, 'seata-server', '{\"category\": \"微服务框架与运行时\", \"version\": \"1.5.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:44:11');
INSERT INTO `operation_logs` VALUES (653, 30, 'admin', '服务管理', 'create', 118, 'tlxx-gateway', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:44:43');
INSERT INTO `operation_logs` VALUES (654, 30, 'admin', '服务管理', 'create', 119, 'tlxx-modules-annex', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:45:06');
INSERT INTO `operation_logs` VALUES (655, 30, 'admin', '服务管理', 'create', 120, 'tlxx-modules-cms', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:45:30');
INSERT INTO `operation_logs` VALUES (656, 30, 'admin', '服务管理', 'create', 121, 'tlxx-modules-magic-api', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:45:54');
INSERT INTO `operation_logs` VALUES (657, 30, 'admin', '服务管理', 'create', 122, 'tlxx-modules-monitor', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:46:16');
INSERT INTO `operation_logs` VALUES (658, 30, 'admin', '服务管理', 'create', 123, 'tlxx-modules-system', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:46:41');
INSERT INTO `operation_logs` VALUES (659, 30, 'admin', '服务管理', 'update', 119, 'tlxx-modules-annex', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:46:48');
INSERT INTO `operation_logs` VALUES (660, 30, 'admin', '服务管理', 'update', 118, 'tlxx-gateway', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 03:46:56');
INSERT INTO `operation_logs` VALUES (661, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:00:11');
INSERT INTO `operation_logs` VALUES (662, 30, 'admin', '服务管理', 'create', 124, 'docker', '{\"category\": \"容器编排\", \"version\": \"26.1.4\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:37:28');
INSERT INTO `operation_logs` VALUES (663, 30, 'admin', '服务管理', 'create', 125, 'docker-compose', '{\"category\": \"容器编排\", \"version\": \"v2.11.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:37:43');
INSERT INTO `operation_logs` VALUES (664, 30, 'admin', '服务管理', 'create', 126, 'ssh', '{\"category\": \"安全与身份认证\", \"version\": \"7.4p1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:38:15');
INSERT INTO `operation_logs` VALUES (665, 30, 'admin', '服务管理', 'create', 127, 'mysqld-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:38:36');
INSERT INTO `operation_logs` VALUES (666, 30, 'admin', '服务管理', 'create', 128, 'node-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:38:55');
INSERT INTO `operation_logs` VALUES (667, 30, 'admin', '服务管理', 'create', 129, 'cadvisor', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:39:16');
INSERT INTO `operation_logs` VALUES (668, 30, 'admin', '服务管理', 'create', 130, 'docker', '{\"category\": \"容器编排\", \"version\": \"26.1.4\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:39:44');
INSERT INTO `operation_logs` VALUES (669, 30, 'admin', '服务管理', 'create', 131, 'docker-compose', '{\"category\": \"容器编排\", \"version\": \"v2.11.2\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:40:00');
INSERT INTO `operation_logs` VALUES (670, 30, 'admin', '服务管理', 'create', 132, 'ssh', '{\"category\": \"安全与身份认证\", \"version\": \"7.4p1\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:40:23');
INSERT INTO `operation_logs` VALUES (671, 30, 'admin', '服务管理', 'create', 133, 'nginx-prometheus-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:41:07');
INSERT INTO `operation_logs` VALUES (672, 30, 'admin', '服务管理', 'create', 134, 'node-exporter', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:41:28');
INSERT INTO `operation_logs` VALUES (673, 30, 'admin', '服务管理', 'create', 135, 'cadvisor', '{\"category\": \"日志、监控与可观测性\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:41:48');
INSERT INTO `operation_logs` VALUES (674, 30, 'admin', '服务管理', 'create', 136, 'logstash', '{\"category\": \"日志、监控与可观测性\", \"version\": \"7.17.18\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:42:12');
INSERT INTO `operation_logs` VALUES (675, 30, 'admin', '服务管理', 'create', 137, 'vehicle-bup', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:42:49');
INSERT INTO `operation_logs` VALUES (676, 30, 'admin', '服务管理', 'create', 138, 'vehicle-ums', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:43:12');
INSERT INTO `operation_logs` VALUES (677, 30, 'admin', '服务管理', 'create', 139, 'vehicle-oauth', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:43:35');
INSERT INTO `operation_logs` VALUES (678, 30, 'admin', '服务管理', 'create', 140, 'vehicle-gateway', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:44:07');
INSERT INTO `operation_logs` VALUES (679, 30, 'admin', '服务管理', 'create', 141, 'sentinel-dashboard', '{\"category\": \"微服务框架与运行时\", \"version\": \"\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 05:44:59');
INSERT INTO `operation_logs` VALUES (680, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:14:57');
INSERT INTO `operation_logs` VALUES (681, 30, 'admin', '账号', 'create', 69, 'confluence', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"http://112.45.109.134:29890/\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:44:53');
INSERT INTO `operation_logs` VALUES (682, 30, 'admin', '账号', 'create', 70, '禅道', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"http://112.45.109.134:52880/my.html\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:47:28');
INSERT INTO `operation_logs` VALUES (683, 30, 'admin', '账号', 'create', 71, '堡垒机', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"http://112.45.109.134:8111/ui/#/profile/improvement\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:48:44');
INSERT INTO `operation_logs` VALUES (684, 30, 'admin', '账号', 'create', 72, 'harbor', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"http://112.45.109.134:11280/harbor/projects\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:50:07');
INSERT INTO `operation_logs` VALUES (685, 30, 'admin', '账号', 'create', 73, 'Jenkins', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"http://112.45.109.134:18080/  \"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:51:10');
INSERT INTO `operation_logs` VALUES (686, 30, 'admin', '账号', 'create', 74, 'Jenkins', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"http://112.45.109.134:17318/\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:51:56');
INSERT INTO `operation_logs` VALUES (687, 30, 'admin', '账号', 'update', 74, 'Jenkins', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:52:06');
INSERT INTO `operation_logs` VALUES (688, 30, 'admin', '账号', 'create', 75, 'harbor', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"https://harbor.huazsz.com/harbor/projects\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:53:54');
INSERT INTO `operation_logs` VALUES (689, 30, 'admin', '账号', 'create', 76, 'ubuntu-desktop', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"https://112.45.109.134:31901/\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:54:43');
INSERT INTO `operation_logs` VALUES (690, 30, 'admin', '账号', 'create', 77, 'car-nacos-prod', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"http://172.24.11.7:8848/nacos\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:56:14');
INSERT INTO `operation_logs` VALUES (691, 30, 'admin', '账号', 'create', 78, '数据中台H5', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"http://h5.sjzctg.com\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:57:25');
INSERT INTO `operation_logs` VALUES (692, 30, 'admin', '账号', 'create', 79, '数据中台PC', '{\"company\": \"四川世纪纵辰科技有限公司\", \"access_url\": \"http://sdc.sjzctg.com\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:58:03');
INSERT INTO `operation_logs` VALUES (693, 30, 'admin', '账号', 'create', 80, 'harbor', '{\"company\": \"四川水电\", \"access_url\": \"https://scsd.huazsz.com/harbor\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:59:16');
INSERT INTO `operation_logs` VALUES (694, 30, 'admin', '账号', 'create', 81, 'nacos', '{\"company\": \"四川水电\", \"access_url\": \"http://10.11.2.38:8848\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 06:59:55');
INSERT INTO `operation_logs` VALUES (695, 30, 'admin', '账号', 'update', 81, 'scsd-nacos-prod', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:01:09');
INSERT INTO `operation_logs` VALUES (696, 30, 'admin', '服务器管理', 'create', 147, '10.11.2.36', '{\"env_type\": \"生产\", \"inner_ip\": \"10.11.2.36\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:02:58');
INSERT INTO `operation_logs` VALUES (697, 30, 'admin', '服务器管理', 'update', 147, '10.11.2.36', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:03:35');
INSERT INTO `operation_logs` VALUES (698, 30, 'admin', '服务器管理', 'create', 148, '10.11.2.37', '{\"env_type\": \"生产\", \"inner_ip\": \"10.11.2.37\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:04:11');
INSERT INTO `operation_logs` VALUES (699, 30, 'admin', '服务器管理', 'update', 148, '10.11.2.37', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:04:25');
INSERT INTO `operation_logs` VALUES (700, 30, 'admin', '服务器管理', 'create', 149, '10.11.2.38', '{\"env_type\": \"生产\", \"inner_ip\": \"10.11.2.38\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:05:04');
INSERT INTO `operation_logs` VALUES (701, 30, 'admin', '服务器管理', 'update', 149, '10.11.2.38', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:05:24');
INSERT INTO `operation_logs` VALUES (702, 30, 'admin', '服务器管理', 'create', 150, '10.11.2.39', '{\"env_type\": \"生产\", \"inner_ip\": \"10.11.2.39\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:06:02');
INSERT INTO `operation_logs` VALUES (703, 30, 'admin', '服务器管理', 'update', 150, '10.11.2.39', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:06:07');
INSERT INTO `operation_logs` VALUES (704, 30, 'admin', '服务器管理', 'create', 151, '10.11.2.40', '{\"env_type\": \"生产\", \"inner_ip\": \"10.11.2.40\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:06:26');
INSERT INTO `operation_logs` VALUES (705, 30, 'admin', '服务器管理', 'update', 151, '10.11.2.40', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:06:31');
INSERT INTO `operation_logs` VALUES (706, 30, 'admin', '服务器管理', 'create', 152, '10.12.1.19', '{\"env_type\": \"生产\", \"inner_ip\": \"10.12.1.19\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:07:25');
INSERT INTO `operation_logs` VALUES (707, 30, 'admin', '服务器管理', 'update', 152, '10.12.1.19', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:07:30');
INSERT INTO `operation_logs` VALUES (708, 30, 'admin', '服务器管理', 'create', 153, '10.12.1.23', '{\"env_type\": \"测试\", \"inner_ip\": \"10.12.1.23\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:08:03');
INSERT INTO `operation_logs` VALUES (709, 30, 'admin', '服务器管理', 'update', 153, '10.12.1.23', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:08:31');
INSERT INTO `operation_logs` VALUES (710, 30, 'admin', '服务器管理', 'create', 154, '10.12.1.24', '{\"env_type\": \"测试\", \"inner_ip\": \"10.12.1.24\"}', '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:08:58');
INSERT INTO `operation_logs` VALUES (711, 30, 'admin', '服务器管理', 'update', 154, '10.12.1.24', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:09:08');
INSERT INTO `operation_logs` VALUES (712, 30, 'admin', '服务器管理', 'update', 151, '10.11.2.40', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:09:27');
INSERT INTO `operation_logs` VALUES (713, 30, 'admin', '服务器管理', 'update', 150, '10.11.2.39', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:09:45');
INSERT INTO `operation_logs` VALUES (714, 30, 'admin', '服务器管理', 'update', 149, '10.11.2.38', NULL, '171.221.82.57', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:09:52');
INSERT INTO `operation_logs` VALUES (715, 30, 'admin', '用户认证', 'login', 30, 'admin', NULL, '192.168.2.2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-04-10 07:10:39');

-- ----------------------------
-- Table structure for project_servers
-- ----------------------------
DROP TABLE IF EXISTS `project_servers`;
CREATE TABLE `project_servers`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `project_id` int NOT NULL COMMENT '项目ID',
  `server_id` int NOT NULL COMMENT '服务器ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_server`(`project_id` ASC, `server_id` ASC) USING BTREE,
  INDEX `idx_project_id`(`project_id` ASC) USING BTREE,
  INDEX `idx_server_id`(`server_id` ASC) USING BTREE,
  CONSTRAINT `project_servers_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `project_servers_ibfk_2` FOREIGN KEY (`server_id`) REFERENCES `servers` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 89 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目-服务器关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of project_servers
-- ----------------------------
INSERT INTO `project_servers` VALUES (20, 9, 63, '2026-04-06 05:59:24');
INSERT INTO `project_servers` VALUES (24, 3, 79, '2026-04-07 07:37:05');
INSERT INTO `project_servers` VALUES (28, 7, 75, '2026-04-07 07:55:54');
INSERT INTO `project_servers` VALUES (29, 7, 76, '2026-04-07 07:55:54');
INSERT INTO `project_servers` VALUES (30, 1, 78, '2026-04-07 09:10:44');
INSERT INTO `project_servers` VALUES (31, 1, 77, '2026-04-07 09:10:44');
INSERT INTO `project_servers` VALUES (33, 9, 131, '2026-04-08 01:30:46');
INSERT INTO `project_servers` VALUES (40, 8, 118, '2026-04-08 02:57:41');
INSERT INTO `project_servers` VALUES (41, 8, 120, '2026-04-08 03:17:20');
INSERT INTO `project_servers` VALUES (47, 5, 129, '2026-04-08 05:13:57');
INSERT INTO `project_servers` VALUES (48, 5, 128, '2026-04-08 05:17:31');
INSERT INTO `project_servers` VALUES (49, 5, 127, '2026-04-08 05:26:02');
INSERT INTO `project_servers` VALUES (50, 6, 126, '2026-04-08 05:27:12');
INSERT INTO `project_servers` VALUES (51, 6, 125, '2026-04-08 05:29:03');
INSERT INTO `project_servers` VALUES (55, 4, 124, '2026-04-08 05:37:03');
INSERT INTO `project_servers` VALUES (56, 4, 123, '2026-04-08 05:37:51');
INSERT INTO `project_servers` VALUES (57, 4, 122, '2026-04-08 05:38:15');
INSERT INTO `project_servers` VALUES (58, 11, 62, '2026-04-08 06:13:17');
INSERT INTO `project_servers` VALUES (59, 11, 61, '2026-04-08 06:13:17');
INSERT INTO `project_servers` VALUES (60, 11, 60, '2026-04-08 06:13:17');
INSERT INTO `project_servers` VALUES (61, 11, 59, '2026-04-08 06:13:17');
INSERT INTO `project_servers` VALUES (62, 11, 58, '2026-04-08 06:13:17');
INSERT INTO `project_servers` VALUES (63, 11, 57, '2026-04-08 06:13:17');
INSERT INTO `project_servers` VALUES (64, 11, 56, '2026-04-08 06:13:17');
INSERT INTO `project_servers` VALUES (65, 8, 119, '2026-04-08 07:27:25');
INSERT INTO `project_servers` VALUES (66, 8, 117, '2026-04-08 07:37:40');
INSERT INTO `project_servers` VALUES (67, 7, 115, '2026-04-08 07:45:28');
INSERT INTO `project_servers` VALUES (68, 7, 114, '2026-04-08 07:45:39');
INSERT INTO `project_servers` VALUES (69, 9, 121, '2026-04-08 07:45:51');
INSERT INTO `project_servers` VALUES (73, 3, 80, '2026-04-08 07:53:29');
INSERT INTO `project_servers` VALUES (74, 10, 132, '2026-04-08 17:57:32');
INSERT INTO `project_servers` VALUES (76, 9, 130, '2026-04-08 18:02:04');
INSERT INTO `project_servers` VALUES (77, 9, 81, '2026-04-08 18:02:47');
INSERT INTO `project_servers` VALUES (78, 2, 147, '2026-04-10 07:03:34');
INSERT INTO `project_servers` VALUES (79, 2, 148, '2026-04-10 07:04:24');
INSERT INTO `project_servers` VALUES (83, 2, 152, '2026-04-10 07:07:29');
INSERT INTO `project_servers` VALUES (84, 2, 153, '2026-04-10 07:08:30');
INSERT INTO `project_servers` VALUES (85, 2, 154, '2026-04-10 07:09:07');
INSERT INTO `project_servers` VALUES (86, 2, 151, '2026-04-10 07:09:26');
INSERT INTO `project_servers` VALUES (87, 2, 150, '2026-04-10 07:09:45');
INSERT INTO `project_servers` VALUES (88, 2, 149, '2026-04-10 07:09:51');

-- ----------------------------
-- Table structure for projects
-- ----------------------------
DROP TABLE IF EXISTS `projects`;
CREATE TABLE `projects`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `project_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '项目名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '项目描述',
  `owner` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '项目负责人',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '运行中' COMMENT '项目状态',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `project_name`(`project_name` ASC) USING BTREE,
  INDEX `idx_project_name`(`project_name` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '项目管理表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of projects
-- ----------------------------
INSERT INTO `projects` VALUES (1, '智慧环保', NULL, NULL, '运行中', NULL, '2026-04-05 14:55:35', '2026-04-05 14:55:35');
INSERT INTO `projects` VALUES (2, '四川水电', NULL, NULL, '运行中', NULL, '2026-04-05 15:25:41', '2026-04-05 15:25:41');
INSERT INTO `projects` VALUES (3, '世纪纵辰数据中台', NULL, NULL, '运行中', NULL, '2026-04-05 16:10:40', '2026-04-06 03:52:11');
INSERT INTO `projects` VALUES (4, '岷水建设招标平台', NULL, NULL, '运行中', NULL, '2026-04-05 18:36:35', '2026-04-06 03:42:48');
INSERT INTO `projects` VALUES (5, '都江堰市工业企业信息化综合服务平台', NULL, NULL, '运行中', NULL, '2026-04-06 03:41:36', '2026-04-06 03:41:36');
INSERT INTO `projects` VALUES (6, '智慧车辆管理系统', NULL, NULL, '运行中', NULL, '2026-04-06 03:43:19', '2026-04-06 03:43:19');
INSERT INTO `projects` VALUES (7, 'OA综合管理系统', NULL, NULL, '运行中', NULL, '2026-04-06 03:44:02', '2026-04-06 03:44:02');
INSERT INTO `projects` VALUES (8, '灌小七城市生活服务平台', NULL, NULL, '运行中', NULL, '2026-04-06 03:51:25', '2026-04-06 03:51:25');
INSERT INTO `projects` VALUES (9, 'CI/CD', NULL, NULL, '运行中', NULL, '2026-04-06 05:08:43', '2026-04-06 05:08:43');
INSERT INTO `projects` VALUES (10, '团队协作与项目管理', NULL, NULL, '运行中', NULL, '2026-04-08 02:40:19', '2026-04-08 02:40:27');
INSERT INTO `projects` VALUES (11, '都经城市服务平台', NULL, NULL, '运行中', NULL, '2026-04-08 06:12:56', '2026-04-08 06:12:56');

-- ----------------------------
-- Table structure for scheduled_tasks
-- ----------------------------
DROP TABLE IF EXISTS `scheduled_tasks`;
CREATE TABLE `scheduled_tasks`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `task_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务类型: script/sql/backup',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '任务描述',
  `cron_expression` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Cron表达式',
  `script_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '脚本内容或SQL语句',
  `script_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '脚本路径（如果是文件）',
  `target_servers` json NULL COMMENT '目标服务器ID列表',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用',
  `last_run_at` datetime NULL DEFAULT NULL COMMENT '上次执行时间',
  `next_run_at` datetime NULL DEFAULT NULL COMMENT '下次执行时间',
  `created_by` int NULL DEFAULT NULL COMMENT '创建人ID',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `execute_command` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '自定义执行命令',
  `script_files` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'JSON数组，存储多个脚本的相对路径',
  `last_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '上次执行状态',
  `last_output` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '上次执行输出',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_task_type`(`task_type` ASC) USING BTREE,
  INDEX `idx_is_active`(`is_active` ASC) USING BTREE,
  INDEX `created_by`(`created_by` ASC) USING BTREE,
  CONSTRAINT `scheduled_tasks_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of scheduled_tasks
-- ----------------------------

-- ----------------------------
-- Table structure for servers
-- ----------------------------
DROP TABLE IF EXISTS `servers`;
CREATE TABLE `servers`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `env_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '环境类型: 测试/生产/智慧环保/水电集团',
  `platform` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '平台',
  `hostname` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '主机名',
  `inner_ip` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '内网IP',
  `mapped_ip` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '云平台映射IP',
  `public_ip` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '互联网IP',
  `cpu` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'CPU',
  `memory` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '内存',
  `sys_disk` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统盘',
  `data_disk` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '数据盘',
  `purpose` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用途',
  `os_user` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统账户',
  `os_password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '系统密码',
  `docker_user` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '普通用户名',
  `docker_password` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '普通用户密码',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注',
  `cert_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '证书路径',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_env_type`(`env_type` ASC) USING BTREE,
  INDEX `idx_inner_ip`(`inner_ip` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 155 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '服务器台账表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of servers
-- ----------------------------
INSERT INTO `servers` VALUES (56, '生产', '天翼云', 'city-01', '192.168.0.128', '', '203.56.12.63', '8', '32', '100', '500', '都经城市服务平台', 'root', 'gAAAAABpz87ICiMlW4tJc83ADDroMeLEQtNxRw1h4LG7YQY8CNHn7tCTFtmQXR5DKAsquVJy2JXDcHJ_dPmQ11OmEioTQJNBgA==', '', NULL, '禁止密码登录', NULL, '2026-04-03 09:58:46', '2026-04-03 14:29:28');
INSERT INTO `servers` VALUES (57, '生产', '天翼云', 'city-02', '192.168.0.63', '', '203.25.213.33', '8', '32', '100', '500', '都经城市服务平台', 'root', 'gAAAAABpz86dnfza1OZuHMzMuHKeIAsa-WhKVwEoWdDSx82Z5QQ-x84leB8-UZe_cH6VgynI177pQwsFk017XOKcXorSJLD6Yg==', '', NULL, '', NULL, '2026-04-03 14:20:56', '2026-04-03 14:28:45');
INSERT INTO `servers` VALUES (58, '生产', '天翼云', 'city-03', '192.168.0.146', '', '203.56.198.20', '8', '32', '100', '4000', '都经城市服务平台', 'root', 'gAAAAABpz87oK7Oaj5eswR8gjOwDH8DOAYgyfB3FXCXHlRuYoxP8OweEfzf_PGdL3bqoZanSnu3UHEXTBkJ36ioDpCKkUG-j_A==', '', NULL, '', NULL, '2026-04-03 14:21:53', '2026-04-03 14:30:00');
INSERT INTO `servers` VALUES (59, '生产', '天翼云', 'city-04', '192.168.0.98', '', '', '8', '32', '100', '4000', '都经城市服务平台', 'root', 'gAAAAABpz88IDcE0rZX6wMHaB0NvIVI9BSVYvYuup6q4WLyr5ma83ao0tHSG3nGoTlCSZDPWsGXq2pONs-ESPGeZ2PD3iWbnPg==', '', NULL, '', NULL, '2026-04-03 14:24:12', '2026-04-03 14:30:32');
INSERT INTO `servers` VALUES (60, '生产', '天翼云', 'city-05', '192.168.0.230', '', '', '8', '32', '100', '4000', '都经城市服务平台', 'root', 'gAAAAABpz88pD9KJoUe58GsGqqUwIdOvH7mBC-qXhkwCmWv841F7iDcyrz_i2zJEpIDij4Z3pXQ4Pa-xjZzVmXXskAFmVEdLzQ==', '', NULL, '', NULL, '2026-04-03 14:24:54', '2026-04-03 14:31:05');
INSERT INTO `servers` VALUES (61, '生产', '天翼云', 'city-06', '192.168.0.86', '', '', '8', '32', '100', '4000', '都经城市服务平台', 'root', 'gAAAAABpz89uwBZPeUR764YSGDUTYywYMvJywnQeZBX6DiDZm1k6UBOz5psBxXUpWGa9ls3k6NAK0JCi6m5ZXd-EdU8Eyfm6bg==', '', NULL, '', NULL, '2026-04-03 14:25:34', '2026-04-03 14:32:14');
INSERT INTO `servers` VALUES (62, '生产', '天翼云', 'city-07', '192.168.0.58', '', '', '8', '32', '100', '500', '都经城市服务平台', 'root', 'gAAAAABpz8-E6vQZnD23kCEYvwajCGv0LU8lgLxqAsDTfXkFF4beqe7JTGnz_gpwPbqFmx5aDjHdc5dwQuChqp6jcQ5FqE3P5Q==', '', NULL, '', NULL, '2026-04-03 14:26:57', '2026-04-03 14:32:36');
INSERT INTO `servers` VALUES (63, '生产', '天翼云', 'nginx', '192.168.0.21', '', '203.56.169.31', '4', '8', '50', '50', '数产对外服务转发nginx', 'root', 'gAAAAABpz-GYgNzF4bD74kzSi5NqRr1XPOeDuPMKxgxfyCZvCNYG8LdwtdNgqhz7DfK8c4r-CcyoVbSF7MDtkHwL6W1jEI8mWWWtGrtwZ3H2z-hCvv4TTZU=', '', NULL, '', '/data/nginx-data/ssl', '2026-04-03 14:35:06', '2026-04-03 15:49:44');
INSERT INTO `servers` VALUES (68, '测试', '都江堰数产私有云', 'm7', '172.24.1.27', '112.45.109.134', NULL, '32', '64', '40', '1000', 'CMS - DEV - worker', 'root', 'gAAAAABp0qnQb2nX44Sv4ZPUxifQzCTroqo9DMo8uYyX15o_NykXOuBd7C9CP_9kCu6K6TBOCDVY5NAt9ZVh7cqKYvcfDGI356CvvcYCSwf8dZQLIbvLsmE=', 'docker', 'gAAAAABp0qnQAia__VB4qyPZU2tRYLmbu_VxPrKVhPgQvS1dwu_LA5i1if0rMvL1HZgD4UyfXexCjCdOuVSfkDmYmZY7AWwEaA==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:32:05');
INSERT INTO `servers` VALUES (69, '测试', '都江堰数产私有云', 'm8', '172.24.1.28', '112.45.109.134', NULL, '16', '32', '40', '300', 'CMS - DEV - worker', 'root', 'gAAAAABp0qntbJfJX0y5aDEpQhsi9-BZoV7LrtOQitZBg-w9cKp0stlGi6UZY-LPxxnncqubQwTyDPfxLCLP8TKwGj5kt3XdoQ==', 'docker', 'gAAAAABp0qntLFKSEbqJV8eA0XFEUDAgolTEe8Qlmp5vBGZz43FDl-R3MxMa6hTBjjI6HHm4A779yzAD8VzQWz2yCNUWzB374Q==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:32:04');
INSERT INTO `servers` VALUES (70, '测试', '都江堰数产私有云', 'm1', '172.24.1.31', '112.45.109.134', NULL, '16', '32', '40', '1000', 'CMS - DEV - worker; TENDER - DEV - worker', 'root', 'gAAAAABp0qoLg2RIAIQjCSl-Kmkk0iYHHjHzkfHsRfolKL2Kn_iu3DkalpX7BKKce5bRr8MA29U7YKXA49YlolgAuZtpBDrp-g==', 'docker', 'gAAAAABp0qoLrxrBxPomREsAR2VP8LaHd6R_9kteeOZBFi95gxz5LwqEekLa2HYBxJAvI5QBLjTQxjFSC-KU1d-3WzCxM69QvQ==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:31:59');
INSERT INTO `servers` VALUES (71, '测试', '都江堰数产私有云', 'm0', '172.24.1.30', '112.45.109.134', NULL, '32', '64', '40', '500', 'TENDER - DEV - worker', 'root', 'gAAAAABp0qql0JzP4MeebunnJvBXDFZuTkphyFunVSMHLbtwTyyHMD8cES5PNTFYMDGQmQyeOxvMDdR3IdPlbz2aLpaCsSkB6A==', 'docker', 'gAAAAABp0qqlCx3r0Qs7K1PMVk2xxRgL9GOzhOgWvPQVWSIwgMtDFSBv21l8jI3TjPiub6XSG9WqpYutIL20Y5w73TnmzbGmJg==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:31:57');
INSERT INTO `servers` VALUES (72, '测试', '都江堰数产私有云', 'm9', '172.24.1.29', '112.45.109.134', NULL, '8', '16', '40', '500', 'TENDER - DEV - worker', 'root', 'gAAAAABp0qr1h9nuIlWozpjuZZt5_v37wt33BvhpQKkn_y1kuVSehhblXBoiXr_VirVoTPq1cTM6FDIrty1RTn4TvkeMH7Vvx-SwkTmqpoTTkhbVdo268r0=', 'docker', 'gAAAAABp0qr1XSPtbZl6H0jl4Ucl_V7JjWbt9DAz9mj0EXivWMe0vpv3HlNQE1cTAupoAKrg9y1GtT7-VREkaX8whVrW0CzYmQ==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:31:55');
INSERT INTO `servers` VALUES (73, '测试', '都江堰数产私有云', 'm2', '172.24.1.32', '112.45.109.134', NULL, '16', '32', '40', '1000', 'CAR - DEV - worker', 'root', 'gAAAAABp0qsM6j3G-PYO-krlP77hT32AkCSvK84b36U0Pw2iyHPPvfnsInkpdWvrcntTGjSbEJ9VIgg7Vpkkx-6ZfxukaE83Pg==', 'docker', 'gAAAAABp0qsMpyHrAh2cUO9BTMTMLSOd8N1CEm0QXB-uaorvGE1PIpLavLYCmXUIQGjI0OXxuCSCC-VfjBtMs697Dti3lyCMMQ==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:31:53');
INSERT INTO `servers` VALUES (74, '测试', '都江堰数产私有云', 'm3', '172.24.1.33', '112.45.109.134', NULL, '16', '32', '40', '1000', 'CAR - DEV - worker', 'root', 'gAAAAABp0qsZvnPo-aQEwtdTRygnPbSWrXaQcUPZH9k4F5q6989btkKLn5cftFd7nbb-vWRQ3AN01KOSOAdtzGTNp09sN0kykw==', 'docker', 'gAAAAABp0qsZiP7Mv-jnEsF3Sga9pqriLmf0JHfNyj4t3rbFQc-Ps1jPA7MCanWXhmGeQ29PN3VQU2w7EwTh3YxMIznyMCbLHg==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:31:51');
INSERT INTO `servers` VALUES (75, '测试', '都江堰数产私有云', 'm6', '172.24.1.36', '112.45.109.134', NULL, '16', '32', '60', '1000', 'OA - DEV - worker', 'root', 'gAAAAABp0qsnhA5Bn6B4pqNAbCWmlVkoxhnGyIZGsyi4EztYSpeWXOpmmGCcM5rGtYT2kw7pQ_ikcfejX3VlfgJpLAyVbNRLtQ==', 'docker', 'gAAAAABp0qsn2AckhjlAnnFwCPYfmo-AkyqCUt_8lB5G9KYyu0lA63Id3TorQvnp2JanII5zZNPFumiSrhbrCHY13ZI9yApvIg==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:31:49');
INSERT INTO `servers` VALUES (76, '测试', '都江堰数产私有云', 'm4', '172.24.1.34', '112.45.109.134', NULL, '8', '16', '60', '500', 'OA - DEV - worker', 'root', 'gAAAAABp0qsuEdYEhxp_-MHADY0rfCI7ahvtLXp150U2ELwzMc2Aatr5qyaOv8lCXzY3MO0zN1PMOEdlsdFBO-2X-Eqm-liUiA==', 'docker', 'gAAAAABp0qsubkXv4C501kxcEp-NLDQwtRdQ9SVCpmy_n0oplJA3uTnWKAEV3OroXtaiL34_JUDR1z_dDZG1Gaef9a27xFPy_w==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:31:46');
INSERT INTO `servers` VALUES (77, '测试', '都江堰数产私有云', 'm5', '172.24.1.35', '112.45.109.134', NULL, '8', '16', '100', '500', 'EPS - DEV - worker', 'root', 'gAAAAABp1LT_pBv_Y_1F0yVWl01LK15XL1XcMz2per2HBLVQSv-K1NuCtuQ8PZJzwzdjbLBVWkmSTvebxV_gmhOZdknzgTj_poUz-K5CVEfXuXj0_Hgbe9E=', 'docker', 'gAAAAABp1LT_3gRW0eW7IrIEgVebAzWCLjKRXPz3mbn-QFzvhUdpzF8Lh8IdaYUQL3tRsMeB3g2eoT4xmvTJkUWMmhJB-ZqesQ==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:40:47');
INSERT INTO `servers` VALUES (78, '测试', '都江堰数产私有云', 'node1', '172.24.1.51', '112.45.109.134', NULL, '8', '32', '40', '500', 'EPS - DEV - worker', 'root', 'gAAAAABp1KCUW6cfE1E9ENmxDU2WfFQvkPFu6xB0z618JYv2aHn_qiYxWpNVgCitgGeKc3V-H8PxaWDE91whOkksgMy9dnx20w==', 'docker', 'gAAAAABp1KCUC56ctQC6aa8ywn7syuj1CSYQgWG-j1GKLyq6l3zYGDblVhYYHe6Gw_qPLPtO-iKPtaEEs_7LqnTU3grss6Yv-w==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-06 02:25:10', '2026-04-07 07:31:44');
INSERT INTO `servers` VALUES (79, '生产', '都江堰数产私有云', 'sdc-data', '172.24.17.38', '112.45.109.134', '', '8', '32', '20', '1000', '数据中台数据库服务器', 'root', 'gAAAAABp1LQh305h0M5QTyGruVS0ZGWVRCi6Skx2Qe5-B_mV3B5xmiy7aiiJ9KRMBqSmxJkpxNd8Xwm4MrEIdjFX0vfwIxHw4g==', '', NULL, '', '', '2026-04-06 03:48:00', '2026-04-07 07:37:05');
INSERT INTO `servers` VALUES (80, '生产', '都江堰数产私有云', 'sdc-app', '172.24.1.53', '112.45.109.134', '', '8', '32', '40', '500', '数据中台应用服务器', 'root', 'gAAAAABp1gl5SQXys1xmix6unCO9c82Ls1R24MVr4rnn5ZJQIUvLNlexn5r602ofbDYgHrYQvSwE_IaQiCPuYVljhIVYEEAHEA==', '', NULL, '', '', '2026-04-06 03:49:55', '2026-04-08 07:53:29');
INSERT INTO `servers` VALUES (81, '生产', '都江堰数产私有云', 'cicd-jenkins-harbor', '172.24.17.31', '112.45.109.134', '', '16', '48', '100', '1000', 'Jenkins-master & Harbor - PROD - worker', 'root', 'gAAAAABp1phH0ZyHnziExJDr4wSABELBxQlHp4sCeCv5Yobd7N48YUvwwVg-KxU2Ur2CdHCvRnCRv5dHWGp6PnHGNXAUJGAJfw==', '', NULL, '通过node_exporter metrics接口获取硬件信息', '', '2026-04-06 05:11:13', '2026-04-08 18:02:47');
INSERT INTO `servers` VALUES (114, '生产', '都江堰数产私有云', 'oaserver1', '172.24.17.28', '112.45.109.134', NULL, '8', '16', '40', '1024', 'OA - PROD - worker', 'root', 'gAAAAABp1gejbl7D4MeNzRTE9S4egL-e6e-Tm0D6RGdS9i1vpMY3rdZscSj9vZdN0UQiwpLJ6kWXzEnTGSk5F_7xwQRulKoqMA==', NULL, NULL, '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 07:45:39');
INSERT INTO `servers` VALUES (115, '生产', '都江堰数产私有云', 'oaserver2', '172.24.17.29', '112.45.109.134', NULL, '24', '48', '40', '1024', 'OA - PROD - worker', 'root', 'gAAAAABp1geY51Aw_R_cpArqflowmIWYtxprqnhzGQjbanWRf0fycmM_er7rItz31oSSNTxOQUuO5JSQDIa9Z7JDlTvaxjz7rg==', '', NULL, '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 07:45:28');
INSERT INTO `servers` VALUES (117, '生产', '都江堰数产私有云', 'gxq20', '172.24.11.20', '112.45.109.134', NULL, '16', '32', '40', '1000', '灌小七 - PROD - worker', 'root', 'gAAAAABp1gXEcGsHahvy9qc4zg8i9y--6Djm5ypgd013RY8bFX4-hT8dVC_bfYZPL6afvlZB4A3HDStp4rkUwGCgmezrIxiCa3mM6WOWF2p2suoQoOQfD0c=', 'docker', 'gAAAAABp1gXE9svykvdSClyUi4PQaozlb4eAzIYQxKPyW5otPQHFjR1jqAN9eg-BCr-xMlF0cnOtXJYmPbT-F9kCWnjn2_2VYA==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 07:37:40');
INSERT INTO `servers` VALUES (118, '生产', '都江堰数产私有云', 'gxq19', '172.24.11.19', '112.45.109.134', NULL, '16', '32', '40', '1000', '灌小七 - PROD - worker', 'root', 'gAAAAABp1cQl1NvpJfp2IV-SfSeGZ1N3MKKxXjhB8TsuxdIOtltTq1vt-_YvPtFidj186-YJY9-xvWGVKACRDhrbKQoaXJxtp2UiMmoUvMn3VprwyCR_sI0=', 'docker', 'gAAAAABp1cQlud38XbdECqcBI27Qsw-6YbpOJXPIrW-mbyeAk2u6BpPCNat8yNg_FVhAxN-Z3EdaD9YrhnGRRivuFhvxtNGlpQ==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 02:57:41');
INSERT INTO `servers` VALUES (119, '生产', '都江堰数产私有云', 'gxq18', '172.24.11.18', '112.45.109.134', NULL, '16', '64', '40', '500', '灌小七 - PROD - worker', 'root', 'gAAAAABp1gNdGCiXvJlBuUkOeyoF4TSOhZbMRApAgvW4IvGOkIH0RkfMBNYvZL5MWvQVIDqawMPIzH1hnSCimtN3SG-jZXZQzPFsOSPWqBIAj9BgGQU9-VI=', 'docker', 'gAAAAABp1gNdSRayCvbjGZaVo7yPuU_oFEnu22RgbENXOSw37NhAuEvkelLbGuD8iRH_7xwPkW-Sbn5k-SmARUUcmsX-pyzR9Q==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 07:27:25');
INSERT INTO `servers` VALUES (120, '生产', '都江堰数产私有云', 'gxq17', '172.24.11.17', '112.45.109.134', NULL, '16', '64', '40', '500', '灌小七 - PROD - worker', 'root', 'gAAAAABp1cjAxPNbJNH1LiN6n7drFOAi7kt7n0UeUi_T190uJ9q8HDVMPXc9fWPYz39JYdC-C5_Re8JvUTlnzlEWHg_XBxpYwB3dd49jsSqogdfVrC3Lk6c=', NULL, NULL, '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 03:17:20');
INSERT INTO `servers` VALUES (121, '生产', '都江堰数产私有云', 'nexus', '172.24.11.16', '112.45.109.134', NULL, '4', '8', '40', '500', '灌小七 - PROD - worker', 'root', 'gAAAAABp1gevXIEOWnZ5fnDoyAOTpYY4I5NnSDHkTTO1a0lm7VuGxlv74c4LoIuNecGErwrskto3ZhiuPxf4oGEGPx_lP4sWqkybVFXTGkW-Te0bJbDQrh0=', 'docker', 'gAAAAABp1gevBY63uQTXfN_S_iWiLq0qgPvB0vSOEEzv-L-DfgXI1k9p8fVFtHi21XgogLdhbpaOY8cJ-_dy5wLvvOyRqKlbLA==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 07:45:51');
INSERT INTO `servers` VALUES (122, '生产', '都江堰数产私有云', 'tender2', '172.24.11.12', '112.45.109.134', NULL, '16', '32', '60', '1000', 'TENDER - PROD - worker', 'root', 'gAAAAABp1enH3ePFv6Gma0BhB9unW3CYtCPl50HdMN7Q-M2ZefoD229PdUTlYexyPjQyHwJIF3XS7DWkZa9apDmx6Rc63-Pcb7-sBM_VbDE8LPRPc0lkBgM=', 'docker', 'gAAAAABp1enHUC0sflV-hijbNjiA6mLBVcjQYykP8QvF8o4qT_x-ua7lxS5LkZdgnHWUoIRuSzBLCv-IPPm_UxFO8i0T5BLQpg==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 05:38:15');
INSERT INTO `servers` VALUES (123, '生产', '都江堰数产私有云', 'tender1', '172.24.11.11', '112.45.109.134', NULL, '8', '16', '60', '500', 'TENDER - PROD - worker', 'root', 'gAAAAABp1emvI2C1G_kJazhIm5NbgHAsTdHzW7aqF9ozKcIEux8pItPOmJ8z1-huWv2bNLg1iA2vlqjmHhBeCzNeuvIcDRrT49IXdiiYMjgMuRp4XsWdNq4=', 'docker', 'gAAAAABp1emv9bQ4N_pbQdr43db1nrfPgb3-REEyCTTYIJ014ZsRAyk0i7TzY356YH8G7zK8jSWu84tuj_GnRR6b2bhXC8wrSw==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 05:37:51');
INSERT INTO `servers` VALUES (124, '生产', '都江堰数产私有云', 'tender0', '172.24.11.10', '112.45.109.134', NULL, '8', '16', '60', '500', 'TENDER - PROD - worker', 'root', 'gAAAAABp1el_2ikzS-d7kCpGKSP88p9KXcD-n6qzKtvNTfnZtsP8yiwYmiGHGcsuv9pIb-dRgp502WsqtOyfHSCh-q4cFg4cZaQ75RE5J5xf40RsDtrqygo=', 'docker', 'gAAAAABp1el_qKLUg15OCbqC1KKBRsUO64uzn43qXWM8kh6RT4WwXXRNU4Z0ZMdIciGOr07s9MDKhUj_A7Ji8-Z26oH_8cG6Wg==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 05:37:03');
INSERT INTO `servers` VALUES (125, '生产', '都江堰数产私有云', 'car7', '172.24.11.7', '112.45.109.134', NULL, '8', '32', '60', '1000', 'CAR - PROD - worker', 'root', 'gAAAAABp1eeftN8z9SUxBcUunsZPAt7dgIKCEH4S-nyzeJsYnh2erGhn0UijZjBsdBH98LHHsa65ravEN2ztYQjayPNHnwIQMmAp7-8i8ZqB9U4pMYqbu2Q=', 'docker', 'gAAAAABp1eefr6e9AioZcra-i8dWCNNEPKYCOwbWZJ6znd1GZ9FIg-aBXlQMWcaG5TeHrvC5zPUXoVTlbxrW8PBN3ihPffOsuQ==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 05:29:03');
INSERT INTO `servers` VALUES (126, '生产', '都江堰数产私有云', 'car6', '172.24.11.6', '112.45.109.134', NULL, '8', '32', '60', '1000', 'CAR - PROD - worker', 'root', 'gAAAAABp1ecw3PJwUN-I8812_ajcLvMLUb1AZAALRKlj_f0wAu4Yicg6uPHWzJeNKnTJ5kNxGVPKSkGNmvVlnICgKztYckEl8b739p_R7pLBkQZIKUNjNe8=', 'docker', 'gAAAAABp1ecwX5-IzNAeh17jIlEw5CbD6_PA3EQLD8pX92jo77Qr0pg9OjXRsjVJQ6saR7ukok5UtdZ9WRZQG2ndpI6WQFNnfA==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 05:27:12');
INSERT INTO `servers` VALUES (127, '生产', '都江堰数产私有云', 'cms5', '172.24.11.5', '112.45.109.134', NULL, '16', '32', '100', '1000', 'CMS - PROD - worker', 'root', 'gAAAAABp1ebqJaa7td2yFpbFvKs6bMWC-kJ0c1YwntK0nuy_W8pAcfCoS15a5wiQznE2oHVzslnIEdx2iN2ll5v_1zHWO9nSSWTOPkVQA6FWWH0I_cRQzOg=', 'docker', 'gAAAAABp1ebq1SYr4bj-Cgijpy_upuwbd1RrlbH2Thn7ZpaRtCTwEaYQ8UoXfRyS3hBkWaPWnkb5KBFOUqu1wqWdnDOysMdFQg==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 05:26:02');
INSERT INTO `servers` VALUES (128, '生产', '都江堰数产私有云', 'cms4', '172.24.11.4', '112.45.109.134', NULL, '32', '64', '100', '1000', 'CMS - PROD - worker', 'root', 'gAAAAABp1eTrMW5MNu957fN4od3lCeruYaXBAoEji7pT8JN8WfTln5hFZ3RxL3YkqGUBYO9UD5AnfePZ1230iM4Em8J6psioNeb04ZRkjnxdUbNQ81uXX-g=', 'docker', 'gAAAAABp1eTrz02xokpzbuvlz9xXCekfH_Isnm9WnsieQEbIjg9pJS_eecF7bdWXOeGneop8OxeMyUCNWE0ipxpbWa7a_nApfQ==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 05:17:31');
INSERT INTO `servers` VALUES (129, '生产', '都江堰数产私有云', 'cms3', '172.24.11.3', '112.45.109.134', NULL, '8', '16', '40', '', 'jumpPROD - PROD - worker', 'root', 'gAAAAABp1eQVJmp5KMMsbyKhrgivU2sjmtQ2uCPRHvfVBqFD-1p52Ndv00hVeiPfv3aqK4f1pLAlSsXbzxwbxD5vUUmoIs9ULjfItMbESstYTSfYvr4nKQw=', 'docker', 'gAAAAABp1eQVDzsc-jNdwWVyTq52LPHxaKDdF0xXZKrTebLrJfTYQUva84giEJA0jabwpUyd3CnAGuCgOhR9gwxqyVIKE59PtQ==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 05:13:57');
INSERT INTO `servers` VALUES (130, '生产', '都江堰数产私有云', 'cicd-jenkins-node', '172.24.11.2', '112.45.109.134', NULL, '8', '16', '40', '500', 'harbor、Jenkins', 'root', 'gAAAAABp1pgco1datiWrzkkWZaNFJ90fSIhYyicYZWHY_YLs16XgmdVhiACkKzWtJxttbz9ZKJ50euSJLg_aJ8VAeBPcBL736f6bl6PZqV-sZ3yDx_xJjs0=', 'docker', 'gAAAAABp1pgc4_4hXJzOaDGfOtK0yOsr2QLgmr-_qKcYtpiba2lJsNVC_f2qxAwS99uQpuZKpGJnXhBV90NZ0t9ema4tvLUjAQ==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 18:02:04');
INSERT INTO `servers` VALUES (131, '生产', '都江堰数产私有云', 'gitlab', '172.24.17.30', '112.45.109.134', NULL, '4', '16', '40', '400', 'gitlab - PROD - worker', 'root', 'gAAAAABp1a_GSyKUTCStva34gSkdF_l405DTgCE-8QTAkYOCw0tkq40KPLNW0febspep8HklWRqKSc_fXDIXSxPngfN0EaC_1w==', NULL, NULL, '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 01:30:46');
INSERT INTO `servers` VALUES (132, '生产', '都江堰数产私有云', 'zentao', '172.24.1.52', '112.45.109.134', NULL, '8', '32', '40', '500', 'ZENTAO - PROD - worker', 'root', 'gAAAAABp1pcMEjk2STf2kfaxP4lyZFgbh8xEwnlaBCZUrcPirbglifG7U86gxSz3Klz1t9FAEI7WYpCsHudfUyw5huqn6_bk-0vVl5pUQ5pusN9WFNdPFYE=', 'docker', 'gAAAAABp1pcMQDTCT5SYq3IhnonNZoUyydjHrmaDBKjcEdLa7L4ECk2R4CD9wraxJepwXu2N0UTtd3RCLKlHhBK6y6kaWVob1w==', '通过node_exporter metrics接口获取硬件信息', NULL, '2026-04-07 07:02:48', '2026-04-08 17:57:32');
INSERT INTO `servers` VALUES (147, '生产', '四川水电政务云', '10.11.2.36', '10.11.2.36', '', '', '8', '16', '100', '300', '', 'root', 'gAAAAABp2KDG8XFkovWh5PLsAVzIyzndOena9Xbuu_DSbu5kyZ9YYrGJ21oShvkqOBj-NgHbVJL_sk_M1I7IkBHg1h1uXI9J-Q==', '', NULL, '', '', '2026-04-10 07:02:58', '2026-04-10 07:03:34');
INSERT INTO `servers` VALUES (148, '生产', '四川水电政务云', '10.11.2.37', '10.11.2.37', '', '', '8', '16', '100', '300', '', 'root', 'gAAAAABp2KD4saA_8kgbP9uc8G9enOdtJdHPJ0pXcEhFIrLYkyCdu9XdDKToeEO-Wu6XFCzPWBY8vgw43_GvW4VchSGChj8vLA==', '', NULL, '', '', '2026-04-10 07:04:11', '2026-04-10 07:04:24');
INSERT INTO `servers` VALUES (149, '生产', '四川水电政务云', '10.11.2.38', '10.11.2.38', '', '', '16', '32', '60', '100', '', 'root', 'gAAAAABp2KI_6zGwJgrca0XhXWP40UZOgfbXt2xvAFXKZ2d_vj4Ssiz6Q6mtw42nFzZ9dbWVHzsf8GGnHdmIT691S0_guYVmSQ==', '', NULL, '', '', '2026-04-10 07:05:03', '2026-04-10 07:09:51');
INSERT INTO `servers` VALUES (150, '生产', '四川水电政务云', '10.11.2.39', '10.11.2.39', '', '', '16', '32', '60', '100', '', 'root', 'gAAAAABp2KI5N4Mm0_gI8b9ubp-4EQSUPnV76hmMkSaTkPKbJZBuI0dYemtEoLrjfZKPaNnQHMMeDD833YaOMVcGwWaiwoKp5w==', '', NULL, '', '', '2026-04-10 07:06:01', '2026-04-10 07:09:45');
INSERT INTO `servers` VALUES (151, '生产', '四川水电政务云', '10.11.2.40', '10.11.2.40', '', '', '16', '32', '60', '100', '', 'root', 'gAAAAABp2KIm7FaVSOfvB2iiSWw-udXp6RyaAB7BrLSFhcPoHpMhio2el3CJ9IWKzMwwYnIokmwHMXNZquxQ1rM0YxUJmvrqHg==', '', NULL, '', '', '2026-04-10 07:06:25', '2026-04-10 07:09:26');
INSERT INTO `servers` VALUES (152, '生产', '四川水电政务云', '10.12.1.19', '10.12.1.19', '', '', '16', '64', '60', '100', '', 'root', 'gAAAAABp2KGxDS21uNItO6ytZVOyu2nadv-7vD4QjvzK1SYqT0rFjrklmbZR80vte190S4ukRaPDeVEwsswSg94NYpt1Fzn-AA==', '', NULL, '流媒体服务器(共用测试环境)\n暂未使用', '', '2026-04-10 07:07:24', '2026-04-10 07:07:29');
INSERT INTO `servers` VALUES (153, '测试', '四川水电政务云', '10.12.1.23', '10.12.1.23', '', '', '8', '32', '100', '300', '', 'root', 'gAAAAABp2KHuElO_kWxhrIUe8ntvGis-I_jMCPIGyOHvXIfpBhzV-qudRbBEOQEAU2pEWYxL1IzRoVVr3IcgfCRYnKGgeL1YEQ==', '', NULL, '', '', '2026-04-10 07:08:03', '2026-04-10 07:08:30');
INSERT INTO `servers` VALUES (154, '测试', '四川水电政务云', '10.12.1.24', '10.12.1.24', '', '', '16', '32', '100', '400', '', 'admin', 'gAAAAABp2KITSn4qKvvWWepOGK-IinRWQkzKHSJtEOrfBRly51tC0gGqS9WAUbh7kGSYK-yf1wW6-CIFOo0fsTXTaHS6-2bblQ==', '', NULL, '', '', '2026-04-10 07:08:57', '2026-04-10 07:09:07');

-- ----------------------------
-- Table structure for services
-- ----------------------------
DROP TABLE IF EXISTS `services`;
CREATE TABLE `services`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `server_id` int NOT NULL COMMENT '所属服务器ID',
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '服务分类',
  `service_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '服务名',
  `version` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '版本',
  `inner_port` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '内网端口',
  `mapped_port` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '外网映射端口',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `project_id` int NULL DEFAULT NULL COMMENT '所属项目ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_server_id`(`server_id` ASC) USING BTREE,
  INDEX `idx_service_name`(`service_name` ASC) USING BTREE,
  CONSTRAINT `services_ibfk_1` FOREIGN KEY (`server_id`) REFERENCES `servers` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 507 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '服务清单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of services
-- ----------------------------
INSERT INTO `services` VALUES (6, 63, '网络服务', 'nginx', '1.27.5', '80', '', '', '2026-04-05 17:29:02', '2026-04-06 04:13:47', NULL);
INSERT INTO `services` VALUES (7, 63, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-06 05:57:14', '2026-04-06 05:57:14', NULL);
INSERT INTO `services` VALUES (8, 63, '容器编排', 'docker-compose', 'v2.39.2', '', '', '', '2026-04-06 05:58:14', '2026-04-06 05:58:14', NULL);
INSERT INTO `services` VALUES (9, 68, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-09 03:47:29', '2026-04-09 03:47:29', NULL);
INSERT INTO `services` VALUES (10, 81, '前端与用户体验服务', 'ubuntu-desktop', '31901', '5901', '31901', '', '2026-04-09 07:39:50', '2026-04-09 07:39:50', 9);
INSERT INTO `services` VALUES (11, 81, '容器编排', 'harbor-jobservice', 'v2.13.2', '', '', '', '2026-04-09 07:40:56', '2026-04-09 07:40:56', 9);
INSERT INTO `services` VALUES (12, 81, '容器编排', 'nginx-photon', 'v2.13.2', '80,443', '17313', 'harbor代理\nhttps://harbor.huazsz.com:17313/harbor/projects\n因域名解析为内网地址，需要修改本机host，将解析指向112.45.109.134', '2026-04-09 07:44:38', '2026-04-09 07:45:47', 9);
INSERT INTO `services` VALUES (13, 81, '容器编排', 'harbor-core', 'v2.13.2', '', '', '', '2026-04-09 07:45:13', '2026-04-09 07:45:13', 9);
INSERT INTO `services` VALUES (14, 81, '容器编排', 'harbor-db', 'v2.13.2', '', '', '', '2026-04-09 07:46:17', '2026-04-09 07:46:35', 9);
INSERT INTO `services` VALUES (15, 81, '容器编排', 'registry-photon', 'v2.13.2', '', '', '', '2026-04-09 07:46:58', '2026-04-09 07:46:58', 9);
INSERT INTO `services` VALUES (16, 81, '容器编排', 'redis', 'v2.13.2', '6379', '', 'harbor仓库独立redis组件，未对外暴露端口，通过容器网络内部访问', '2026-04-09 07:48:32', '2026-04-09 07:48:32', 9);
INSERT INTO `services` VALUES (17, 81, '容器编排', 'harbor-portal', 'v2.13.2', '', '', '', '2026-04-09 07:49:03', '2026-04-09 07:49:03', 9);
INSERT INTO `services` VALUES (18, 81, '容器编排', 'harbor-registryctl', 'v2.13.2', '', '', '', '2026-04-09 07:49:29', '2026-04-09 07:49:29', 9);
INSERT INTO `services` VALUES (19, 81, '容器编排', 'harbor-log', 'v2.13.2', '', '', '', '2026-04-09 07:49:49', '2026-04-09 07:49:49', 9);
INSERT INTO `services` VALUES (20, 81, 'CI/CD流水线', 'jenkins', '2.543', '18080,50000', '17318', 'Jenkins master节点', '2026-04-09 07:52:45', '2026-04-09 07:52:45', 9);
INSERT INTO `services` VALUES (21, 81, '日志、监控与可观测性', 'node-exporter', 'v1.9.1', '9100', '', '', '2026-04-09 07:53:32', '2026-04-09 07:58:35', NULL);
INSERT INTO `services` VALUES (22, 81, '日志、监控与可观测性', 'cadvisor', 'v0.52.0', '8080', '', '', '2026-04-09 07:54:55', '2026-04-09 07:58:36', NULL);
INSERT INTO `services` VALUES (23, 81, '安全与身份认证', 'ssh', '8.9p1', '22', '17312', '', '2026-04-09 07:57:08', '2026-04-09 07:57:08', NULL);
INSERT INTO `services` VALUES (24, 81, '容器编排', 'docker-compose', 'v5.0.0', '', '', '', '2026-04-09 07:59:41', '2026-04-09 07:59:41', 9);
INSERT INTO `services` VALUES (25, 131, '安全与身份认证', 'ssh', '8.9p1', '22', '17302', '', '2026-04-09 08:16:44', '2026-04-09 08:16:44', NULL);
INSERT INTO `services` VALUES (26, 131, '容器编排', 'docker', '29.1.2', '', '', '', '2026-04-09 08:19:32', '2026-04-09 08:19:32', NULL);
INSERT INTO `services` VALUES (27, 131, '容器编排', 'docker-compose', 'v5.0.0', '', '', '', '2026-04-09 08:19:51', '2026-04-09 08:19:51', NULL);
INSERT INTO `services` VALUES (28, 131, 'CI/CD流水线', 'gitlab-ce', '15.2.2-ce.0 ', '80,443', '17380', '代码仓库', '2026-04-09 08:21:00', '2026-04-09 08:21:00', 9);
INSERT INTO `services` VALUES (29, 131, '日志、监控与可观测性', 'node-exporter', 'v1.9.1', '9100', '', '', '2026-04-09 08:25:29', '2026-04-09 08:25:29', NULL);
INSERT INTO `services` VALUES (30, 131, '日志、监控与可观测性', 'cadvisor', 'v0.52.0', '8080', '', '', '2026-04-09 08:27:56', '2026-04-09 08:27:56', NULL);
INSERT INTO `services` VALUES (31, 114, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-09 08:32:44', '2026-04-09 08:32:44', NULL);
INSERT INTO `services` VALUES (32, 114, '容器编排', 'docker-compose', 'v2.39.2', '', '', '', '2026-04-09 08:33:11', '2026-04-09 08:33:11', NULL);
INSERT INTO `services` VALUES (33, 114, '网络服务', 'nginx', '1.20.2', '80,443', '28080,28443', '', '2026-04-09 08:34:43', '2026-04-09 08:34:43', 7);
INSERT INTO `services` VALUES (34, 114, '安全与身份认证', 'ssh', '7.4p1', '22', '17282', '', '2026-04-09 08:38:02', '2026-04-09 08:38:02', NULL);
INSERT INTO `services` VALUES (35, 114, '微服务框架与运行时', 'asset', '', '10088', '', '', '2026-04-09 08:38:49', '2026-04-09 08:38:49', 7);
INSERT INTO `services` VALUES (36, 114, '微服务框架与运行时', 'bup', '', '11112', '', '', '2026-04-09 08:50:46', '2026-04-09 08:50:46', 7);
INSERT INTO `services` VALUES (37, 114, '微服务框架与运行时', 'camunda', '', '10076', '', '', '2026-04-09 08:51:15', '2026-04-09 08:51:15', 7);
INSERT INTO `services` VALUES (38, 114, '微服务框架与运行时', 'file', '', '10100', '', '', '2026-04-09 08:51:40', '2026-04-09 08:51:40', 7);
INSERT INTO `services` VALUES (39, 114, '微服务框架与运行时', 'gateway', '', '9999', '', '', '2026-04-09 08:52:06', '2026-04-09 08:52:06', 7);
INSERT INTO `services` VALUES (40, 114, '微服务框架与运行时', 'meeting', '', '10086', '', '', '2026-04-09 08:52:22', '2026-04-09 08:52:22', 7);
INSERT INTO `services` VALUES (41, 114, '微服务框架与运行时', 'oasystem', '', '10087', '', '', '2026-04-09 08:54:09', '2026-04-09 08:54:09', 7);
INSERT INTO `services` VALUES (42, 114, '微服务框架与运行时', 'oauth', '', '11111', '', '', '2026-04-09 08:55:13', '2026-04-09 08:55:13', 7);
INSERT INTO `services` VALUES (43, 114, '微服务框架与运行时', 'project', '', '10089', '', '', '2026-04-09 08:55:47', '2026-04-09 08:55:47', 7);
INSERT INTO `services` VALUES (44, 114, '日志、监控与可观测性', 'node-exporter', 'v1.9.1', '9100', '', '', '2026-04-09 09:28:20', '2026-04-09 09:28:20', NULL);
INSERT INTO `services` VALUES (45, 69, '日志、监控与可观测性', 'cadvisor', 'v0.52.0', '', '', '', '2026-04-09 09:32:33', '2026-04-09 09:32:33', NULL);
INSERT INTO `services` VALUES (46, 115, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 02:56:21', '2026-04-10 02:56:21', NULL);
INSERT INTO `services` VALUES (47, 115, '容器编排', 'docker-compose', 'v2.39.2', '', '', '', '2026-04-10 02:56:36', '2026-04-10 02:56:36', NULL);
INSERT INTO `services` VALUES (48, 115, '安全与身份认证', 'ssh', '7.4p1', '22', '17292', '', '2026-04-10 02:57:02', '2026-04-10 02:57:02', NULL);
INSERT INTO `services` VALUES (49, 115, 'NoSQL数据库', 'elasticsearch', '7.13.2', '9200,9300', '', '', '2026-04-10 02:58:49', '2026-04-10 02:58:49', 7);
INSERT INTO `services` VALUES (50, 115, 'NoSQL数据库', 'mongo', '7', '27017', '', '', '2026-04-10 02:59:11', '2026-04-10 02:59:11', 7);
INSERT INTO `services` VALUES (51, 115, '关系型数据库', 'redis', '6', '6379', '', '', '2026-04-10 02:59:48', '2026-04-10 02:59:48', 7);
INSERT INTO `services` VALUES (52, 115, '关系型数据库', 'mysql', '8.0.28', '3306', '', '', '2026-04-10 03:00:07', '2026-04-10 03:00:07', 7);
INSERT INTO `services` VALUES (53, 115, '存储服务', 'minio', 'RELEASE.2024-09-09T16-59-28Z', '9000,9001', '', '', '2026-04-10 03:00:33', '2026-04-10 03:00:33', 7);
INSERT INTO `services` VALUES (54, 115, '消息队列', 'rabbitmq', '4.2.0', '5671,5672,15671,15672,25672', '', '', '2026-04-10 03:01:22', '2026-04-10 03:01:22', 7);
INSERT INTO `services` VALUES (55, 115, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848,9848', '29848', '', '2026-04-10 03:01:56', '2026-04-10 03:01:56', 7);
INSERT INTO `services` VALUES (56, 115, '日志、监控与可观测性', 'grafana', '12.2-ubuntu', '3000', '29300', '', '2026-04-10 03:02:26', '2026-04-10 03:02:26', NULL);
INSERT INTO `services` VALUES (57, 115, '日志、监控与可观测性', 'prometheus', 'v3.6.0', '9090', '', '', '2026-04-10 03:03:17', '2026-04-10 03:03:17', NULL);
INSERT INTO `services` VALUES (58, 115, '日志、监控与可观测性', 'node-exporter', 'v1.9.1', '9100', '', '', '2026-04-10 03:03:42', '2026-04-10 03:03:42', NULL);
INSERT INTO `services` VALUES (59, 115, '日志、监控与可观测性', 'cadvisor', 'v0.52.0', '8080', '', '', '2026-04-10 03:04:02', '2026-04-10 03:04:02', NULL);
INSERT INTO `services` VALUES (60, 115, '团队协作与项目管理', 'confluence', '8.5.5', '8090', '29890', '', '2026-04-10 03:06:29', '2026-04-10 03:06:29', 10);
INSERT INTO `services` VALUES (61, 130, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 03:07:17', '2026-04-10 03:07:17', NULL);
INSERT INTO `services` VALUES (62, 130, '容器编排', 'docker-compose', 'v2.11.2', '', '', '', '2026-04-10 03:07:35', '2026-04-10 03:07:35', NULL);
INSERT INTO `services` VALUES (63, 130, '安全与身份认证', 'ssh', '7.4p1', '22', '32022', '', '2026-04-10 03:07:58', '2026-04-10 03:07:58', NULL);
INSERT INTO `services` VALUES (64, 130, 'CI/CD流水线', 'harbor-jobservice', 'v2.8.2 ', '', '', '', '2026-04-10 03:08:32', '2026-04-10 03:08:32', 9);
INSERT INTO `services` VALUES (65, 130, 'CI/CD流水线', 'nginx-photon', 'v2.8.2 ', '40080', '11280', '', '2026-04-10 03:09:18', '2026-04-10 03:10:59', 9);
INSERT INTO `services` VALUES (66, 130, 'CI/CD流水线', 'harbor-core', 'v2.8.2 ', '', '', '', '2026-04-10 03:10:43', '2026-04-10 03:10:43', 9);
INSERT INTO `services` VALUES (67, 130, 'CI/CD流水线', 'registry-photon', 'v2.8.2 ', '', '', '', '2026-04-10 03:11:46', '2026-04-10 03:11:46', 9);
INSERT INTO `services` VALUES (68, 130, 'CI/CD流水线', 'harbor-db', 'v2.8.2 ', '', '', '', '2026-04-10 03:12:07', '2026-04-10 03:12:07', 9);
INSERT INTO `services` VALUES (69, 130, 'CI/CD流水线', 'harbor-registryctl', 'v2.8.2 ', '', '', '', '2026-04-10 03:12:33', '2026-04-10 03:12:45', 9);
INSERT INTO `services` VALUES (70, 130, 'CI/CD流水线', 'redis-photon', 'v2.8.2 ', '', '', '', '2026-04-10 03:13:07', '2026-04-10 03:13:07', 9);
INSERT INTO `services` VALUES (71, 130, 'CI/CD流水线', 'harbor-log', 'v2.8.2', '', '', '', '2026-04-10 03:13:37', '2026-04-10 03:13:37', 9);
INSERT INTO `services` VALUES (72, 130, 'CI/CD流水线', 'harbor-portal', 'v2.8.2 ', '', '', '', '2026-04-10 03:13:53', '2026-04-10 03:13:53', 9);
INSERT INTO `services` VALUES (73, 130, 'CI/CD流水线', 'jenkins', '2.13.2', '18080', '18080', '', '2026-04-10 03:14:27', '2026-04-10 03:14:27', 9);
INSERT INTO `services` VALUES (74, 130, 'CI/CD流水线', 'nexus3', '', '8081', '8081', '', '2026-04-10 03:14:54', '2026-04-10 03:14:54', 9);
INSERT INTO `services` VALUES (75, 130, '关系型数据库', 'redis', '6.2.6', '6379', '', '', '2026-04-10 03:15:46', '2026-04-10 03:15:46', 5);
INSERT INTO `services` VALUES (76, 130, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', '2026-04-10 03:16:12', '2026-04-10 03:16:12', NULL);
INSERT INTO `services` VALUES (77, 130, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 03:16:59', '2026-04-10 03:16:59', NULL);
INSERT INTO `services` VALUES (78, 130, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 03:17:17', '2026-04-10 03:17:17', NULL);
INSERT INTO `services` VALUES (79, 129, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 03:21:06', '2026-04-10 03:21:06', NULL);
INSERT INTO `services` VALUES (80, 129, '容器编排', 'docker-compose', 'v2.11.2', '', '', '', '2026-04-10 03:21:22', '2026-04-10 03:21:22', NULL);
INSERT INTO `services` VALUES (81, 129, '安全与身份认证', 'ssh', '7.4p1', '22', '33022', '', '2026-04-10 03:21:51', '2026-04-10 03:21:51', NULL);
INSERT INTO `services` VALUES (82, 129, '堡垒机', 'lion', 'v3.10.12', '4822', '', '', '2026-04-10 03:24:31', '2026-04-10 03:24:31', NULL);
INSERT INTO `services` VALUES (83, 129, '堡垒机', 'core-ce', 'v3.10.12', '8080', '', '', '2026-04-10 03:24:53', '2026-04-10 03:24:53', NULL);
INSERT INTO `services` VALUES (84, 129, '堡垒机', 'redis', 'v3.10.12', '6379', '', '', '2026-04-10 03:25:43', '2026-04-10 03:25:43', NULL);
INSERT INTO `services` VALUES (85, 129, '堡垒机', 'koko', 'v3.10.12', '2222,5000', '', '', '2026-04-10 03:26:09', '2026-04-10 03:26:09', NULL);
INSERT INTO `services` VALUES (86, 129, '堡垒机', 'magnus', 'v3.10.12', '8088,33061,33062,54320,63790', '33061,33062,63790', '', '2026-04-10 03:29:14', '2026-04-10 03:29:14', NULL);
INSERT INTO `services` VALUES (87, 129, '堡垒机', 'kael', 'v3.10.12', '8083', '', '', '2026-04-10 03:29:32', '2026-04-10 03:29:32', NULL);
INSERT INTO `services` VALUES (88, 129, '堡垒机', 'chen', 'v3.10.12', '8082', '', '', '2026-04-10 03:29:50', '2026-04-10 03:29:50', NULL);
INSERT INTO `services` VALUES (89, 129, '堡垒机', 'web', 'v3.10.12', '80,443,8111', '13080,13443,8111', '', '2026-04-10 03:30:27', '2026-04-10 03:30:27', NULL);
INSERT INTO `services` VALUES (90, 129, '堡垒机', 'mariadb', '10.6', '3306', '', '', '2026-04-10 03:30:51', '2026-04-10 03:30:51', NULL);
INSERT INTO `services` VALUES (91, 129, '网络服务', 'nginx', '1.27.4', '18080', '', '', '2026-04-10 03:31:29', '2026-04-10 03:31:29', NULL);
INSERT INTO `services` VALUES (92, 129, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', '2026-04-10 03:31:51', '2026-04-10 03:31:51', NULL);
INSERT INTO `services` VALUES (93, 129, '日志、监控与可观测性', 'prometheus', '', '9090', '', '', '2026-04-10 03:32:16', '2026-04-10 03:32:16', NULL);
INSERT INTO `services` VALUES (94, 129, '日志、监控与可观测性', 'syslog-ng', '', '514,601', '', '', '2026-04-10 03:32:42', '2026-04-10 03:32:42', NULL);
INSERT INTO `services` VALUES (95, 129, '日志、监控与可观测性', 'blackbox-exporter', '', '9115', '', '', '2026-04-10 03:33:04', '2026-04-10 03:33:04', NULL);
INSERT INTO `services` VALUES (96, 129, '日志、监控与可观测性', 'prometheus-webhook-dingtalk', '', '8060', '', '', '2026-04-10 03:33:23', '2026-04-10 03:33:23', NULL);
INSERT INTO `services` VALUES (97, 129, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 03:33:40', '2026-04-10 03:33:40', NULL);
INSERT INTO `services` VALUES (98, 129, '安全与身份认证', 'cadvisor', '', '8080', '', '', '2026-04-10 03:33:59', '2026-04-10 03:33:59', NULL);
INSERT INTO `services` VALUES (99, 129, '日志、监控与可观测性', 'grafana', '', '13000', '', '', '2026-04-10 03:34:22', '2026-04-10 03:34:22', NULL);
INSERT INTO `services` VALUES (100, 129, '日志、监控与可观测性', 'snmp-exporter', '', '9116', '', '', '2026-04-10 03:34:41', '2026-04-10 03:34:41', NULL);
INSERT INTO `services` VALUES (101, 129, '日志、监控与可观测性', 'promtail', '', '1514,9080', '', '', '2026-04-10 03:35:03', '2026-04-10 03:35:03', NULL);
INSERT INTO `services` VALUES (102, 129, '日志、监控与可观测性', 'loki', '', '3100', '', '', '2026-04-10 03:35:47', '2026-04-10 03:35:47', NULL);
INSERT INTO `services` VALUES (103, 128, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 03:37:29', '2026-04-10 03:37:29', NULL);
INSERT INTO `services` VALUES (104, 128, '容器编排', 'docker-compose', 'v2.11.2', '', '', '', '2026-04-10 03:37:44', '2026-04-10 03:37:44', NULL);
INSERT INTO `services` VALUES (105, 128, '安全与身份认证', 'ssh', '7.4p1', '22', '34022', '', '2026-04-10 03:38:06', '2026-04-10 03:38:06', NULL);
INSERT INTO `services` VALUES (106, 128, '关系型数据库', 'redis', '7.4.2', '6379', '', '', '2026-04-10 03:38:45', '2026-04-10 03:38:45', 5);
INSERT INTO `services` VALUES (107, 128, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', '2026-04-10 03:39:26', '2026-04-10 03:39:26', NULL);
INSERT INTO `services` VALUES (108, 128, '日志、监控与可观测性', 'elasticsearch-exporter', '', '9114', '', '', '2026-04-10 03:39:45', '2026-04-10 03:39:45', NULL);
INSERT INTO `services` VALUES (109, 128, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', '2026-04-10 03:40:03', '2026-04-10 03:40:03', NULL);
INSERT INTO `services` VALUES (110, 128, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 03:40:23', '2026-04-10 03:40:23', NULL);
INSERT INTO `services` VALUES (111, 128, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 03:40:37', '2026-04-10 03:40:37', NULL);
INSERT INTO `services` VALUES (112, 128, '日志、监控与可观测性', 'promtail', '', '1514,9080', '', '', '2026-04-10 03:41:00', '2026-04-10 03:41:00', NULL);
INSERT INTO `services` VALUES (113, 128, '网络服务', 'nginx', '1.18.0', '80,443,10003,10004,10005', '30080,30443,10003,10004,10005', '', '2026-04-10 03:41:58', '2026-04-10 03:41:58', NULL);
INSERT INTO `services` VALUES (114, 128, '存储服务', 'minio', 'RELEASE.2021-06-17T00-10-46Z', '9000', '9000', '', '2026-04-10 03:42:24', '2026-04-10 03:43:01', 5);
INSERT INTO `services` VALUES (115, 128, 'NoSQL数据库', 'elasticsearch', '7.12.1', '9200,9300', '', '', '2026-04-10 03:42:51', '2026-04-10 03:42:51', 5);
INSERT INTO `services` VALUES (116, 128, '服务发现与配置中心', 'nacos', '1.4.2', '8848,9848', '', '', '2026-04-10 03:43:31', '2026-04-10 03:43:31', 5);
INSERT INTO `services` VALUES (117, 128, '微服务框架与运行时', 'seata-server', '1.5.2', '7091,8091', '7091', '', '2026-04-10 03:44:10', '2026-04-10 03:44:10', 5);
INSERT INTO `services` VALUES (118, 128, '微服务框架与运行时', 'tlxx-gateway', '', '9010', '9010', '', '2026-04-10 03:44:43', '2026-04-10 03:46:55', 5);
INSERT INTO `services` VALUES (119, 128, '微服务框架与运行时', 'tlxx-modules-annex', '', '9012', '9012', '', '2026-04-10 03:45:06', '2026-04-10 03:46:48', 5);
INSERT INTO `services` VALUES (120, 128, '微服务框架与运行时', 'tlxx-modules-cms', '', '9018', '9018', '', '2026-04-10 03:45:29', '2026-04-10 03:45:29', 5);
INSERT INTO `services` VALUES (121, 128, '微服务框架与运行时', 'tlxx-modules-magic-api', '', '9014', '9014', '', '2026-04-10 03:45:54', '2026-04-10 03:45:54', 5);
INSERT INTO `services` VALUES (122, 128, '微服务框架与运行时', 'tlxx-modules-monitor', '', '9011', '9011', '', '2026-04-10 03:46:15', '2026-04-10 03:46:15', 5);
INSERT INTO `services` VALUES (123, 128, '微服务框架与运行时', 'tlxx-modules-system', '', '9016', '9016', '', '2026-04-10 03:46:40', '2026-04-10 03:46:40', 5);
INSERT INTO `services` VALUES (124, 127, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 05:37:28', '2026-04-10 05:37:28', NULL);
INSERT INTO `services` VALUES (125, 127, '容器编排', 'docker-compose', 'v2.11.2', '', '', '', '2026-04-10 05:37:42', '2026-04-10 05:37:42', NULL);
INSERT INTO `services` VALUES (126, 127, '安全与身份认证', 'ssh', '7.4p1', '22', '35022', '', '2026-04-10 05:38:14', '2026-04-10 05:38:14', NULL);
INSERT INTO `services` VALUES (127, 127, '日志、监控与可观测性', 'mysqld-exporter', '', '9104', '', '', '2026-04-10 05:38:35', '2026-04-10 05:38:35', NULL);
INSERT INTO `services` VALUES (128, 127, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 05:38:54', '2026-04-10 05:38:54', NULL);
INSERT INTO `services` VALUES (129, 127, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 05:39:15', '2026-04-10 05:39:15', NULL);
INSERT INTO `services` VALUES (130, 126, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 05:39:44', '2026-04-10 05:39:44', NULL);
INSERT INTO `services` VALUES (131, 126, '容器编排', 'docker-compose', 'v2.11.2', '', '', '', '2026-04-10 05:39:59', '2026-04-10 05:39:59', NULL);
INSERT INTO `services` VALUES (132, 126, '安全与身份认证', 'ssh', '7.4p1', '22', '36022', '', '2026-04-10 05:40:23', '2026-04-10 05:40:23', NULL);
INSERT INTO `services` VALUES (133, 126, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', '2026-04-10 05:41:06', '2026-04-10 05:41:06', NULL);
INSERT INTO `services` VALUES (134, 126, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 05:41:28', '2026-04-10 05:41:28', NULL);
INSERT INTO `services` VALUES (135, 126, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 05:41:47', '2026-04-10 05:41:47', NULL);
INSERT INTO `services` VALUES (136, 126, '日志、监控与可观测性', 'logstash', '7.17.18', '', '', '', '2026-04-10 05:42:11', '2026-04-10 05:42:11', NULL);
INSERT INTO `services` VALUES (137, 126, '微服务框架与运行时', 'vehicle-bup', '', '11112', '', '', '2026-04-10 05:42:49', '2026-04-10 05:42:49', 6);
INSERT INTO `services` VALUES (138, 126, '微服务框架与运行时', 'vehicle-ums', '', '11113', '', '', '2026-04-10 05:43:12', '2026-04-10 05:43:12', 6);
INSERT INTO `services` VALUES (139, 126, '微服务框架与运行时', 'vehicle-oauth', '', '11111', '', '', '2026-04-10 05:43:34', '2026-04-10 05:43:34', 6);
INSERT INTO `services` VALUES (140, 126, '微服务框架与运行时', 'vehicle-gateway', '', '9999', '', '', '2026-04-10 05:44:07', '2026-04-10 05:44:07', 6);
INSERT INTO `services` VALUES (141, 126, '微服务框架与运行时', 'sentinel-dashboard', '', '8858,8989', '', '', '2026-04-10 05:44:59', '2026-04-10 05:44:59', 6);
INSERT INTO `services` VALUES (142, 125, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (143, 125, '容器编排', 'docker-compose', 'v2.11.2', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (144, 125, '网络服务', 'ssh', '7.4p1', '22', '37022', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (145, 125, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848,9848', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (146, 125, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000,9001', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (147, 125, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (148, 125, '分布式缓存', 'redis', '7.4.2', '6379', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (149, 125, '消息队列', 'rabbitmq', 'management', '4369,5671,5672,15671,15672,15692', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (150, 125, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (151, 125, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (152, 125, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (153, 125, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (154, 124, '容器编排', 'docker', '28.1.1', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (155, 124, '容器编排', 'docker-compose', 'v2.35.1', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (156, 124, '网络服务', 'ssh', '7.4p1', '22', '40022', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (157, 124, '网络服务', 'nginx', '1.20.1', '80,443,8080,8099,18080', '40080,40443,8098,8099', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (158, 124, '微服务框架与运行时', 'tender-uas', '', '10103', '10103', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (159, 124, '微服务框架与运行时', 'tender-bup', '', '10102', '10102', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (160, 124, 'API网关与服务网格', 'tender-gateway', '', '7777,8989', '27777,28989', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (161, 124, '安全与身份认证', 'tender-oauth', '', '10101', '10101', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (162, 124, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (163, 124, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (164, 124, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (165, 123, '容器编排', 'docker', '28.1.1', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (166, 123, '容器编排', 'docker-compose', 'v2.35.1', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (167, 123, '网络服务', 'ssh', '7.4p1', '22', '41022', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (168, 123, '微服务框架与运行时', 'tender-uas', '', '10103', '10103', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (169, 123, '微服务框架与运行时', 'tender-bup', '', '10102', '10102', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (170, 123, 'API网关与服务网格', 'tender-gateway', '', '7777,8989', '27777,28989', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (171, 123, '安全与身份认证', 'tender-oauth', '', '10101', '10101', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (172, 123, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (173, 123, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (174, 122, '容器编排', 'docker', '28.1.1', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (175, 122, '容器编排', 'docker-compose', 'v2.35.1', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (176, 122, '网络服务', 'ssh', '7.4p1', '22', '42022', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (177, 122, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848,9848', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (178, 122, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000,9001', '11290,11291', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (179, 122, '分布式缓存', 'redis', '7.4.2', '6379', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (180, 122, '消息队列', 'rabbitmq', 'management', '4369,5671,5672,15671,15672,15692', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (181, 122, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (182, 122, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (183, 122, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (184, 122, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (185, 122, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (186, 121, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (187, 121, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (188, 121, '网络服务', 'ssh', '7.4p1', '22', '22068', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (189, 121, 'CI/CD流水线', 'nexus3', '', '8081', '18081', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (190, 121, '分布式缓存', 'redis', '6.2.6', '6379', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (191, 121, '网络服务', 'nginx', '1.28.0', '80,443,8080,8443,18080', '11680,11643', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (192, 121, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (193, 121, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (194, 121, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (195, 120, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (196, 120, '容器编排', 'docker-compose', 'v2.39.2', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (197, 120, '网络服务', 'ssh', '7.4p1', '22', '22069', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (198, 120, '微服务框架与运行时', 'pay-pay', '', '31008', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (199, 120, '分布式缓存', 'redis', '6.2.6', '6379', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (200, 120, '网络服务', 'keepalived', '', '80,443,31508,10080', '12180,12143,12108,12181', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (201, 120, '网络服务', 'nginx', '1.27.5', '80,1072,5072,10080,10672,17091,180', '11780,11743', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (202, 120, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (203, 120, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (204, 120, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (205, 120, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (206, 119, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (207, 119, '容器编排', 'docker-compose', 'v2.39.2', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (208, 119, '网络服务', 'ssh', '7.4p1', '22', '22070', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (209, 119, '服务发现与配置中心', 'nacos', '2.2.0', '8848,9848', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (210, 119, '微服务框架与运行时', 'pay-pay', '', '31008', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (211, 119, '微服务框架与运行时', 'seata-server', '1.6.1', '7091,8091', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (212, 119, '数据平台与大数据', 'kafka-ui', '', '38080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (213, 119, '消息队列', 'cp-kafka', '', '9092', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (214, 119, '服务发现与配置中心', 'zookeeper', '3.8.0', '2181', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (215, 119, '消息队列', 'rabbitmq', 'management', '4369,5671,5672,15671,15672,15692', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (216, 119, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (217, 119, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000,9001', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (218, 119, '分布式缓存', 'redis', '6.2.6', '6379', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (219, 119, '网络服务', 'keepalived', '', '80,1072,5072,10080,10672,17091,180', '12280,12243,12208,12281', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (220, 119, '网络服务', 'nginx', '1.27.5', '80,19000,19001,31508', '11880,11843', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (221, 119, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (222, 119, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (223, 119, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (224, 119, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (225, 119, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (226, 118, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (227, 118, '容器编排', 'docker-compose', 'v2.39.2', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (228, 118, '网络服务', 'ssh', '7.4p1', '22', '22071', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (229, 118, '服务发现与配置中心', 'nacos', '2.2.0', '8848,9848', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (230, 118, '微服务框架与运行时', 'seata-server', '1.6.1', '7091,8091', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (231, 118, '数据平台与大数据', 'kafka-ui', '', '38080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (232, 118, '消息队列', 'cp-kafka', '', '9092', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (233, 118, '服务发现与配置中心', 'zookeeper', '3.8.0', '2181', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (234, 118, '消息队列', 'rabbitmq', 'management', '4369,5671,5672,15671,15672,15692', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (235, 118, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (236, 118, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000,9001', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (237, 118, '分布式缓存', 'redis', '6.2.6', '6379', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (238, 118, '网络服务', 'haproxy', '', '23300,23306', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (239, 118, '网络服务', 'keepalived', '', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (240, 118, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (241, 118, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (242, 118, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (243, 118, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (244, 118, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (245, 117, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (246, 117, '容器编排', 'docker-compose', 'v2.38.2', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (247, 117, '网络服务', 'ssh', '7.4p1', '22', '22072', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (248, 117, '服务发现与配置中心', 'nacos', '2.2.0', '8848,9848', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (249, 117, '微服务框架与运行时', 'seata-server', '1.6.1', '7091,8091', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (250, 117, '数据平台与大数据', 'kafka-ui', '', '38080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (251, 117, '消息队列', 'cp-kafka', '', '9092', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (252, 117, '服务发现与配置中心', 'zookeeper', '3.8.0', '2181', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (253, 117, '消息队列', 'rabbitmq', 'management', '4369,5671,5672,15671,15672,15692', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (254, 117, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (255, 117, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000,9001', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (256, 117, '分布式缓存', 'redis', '6.2.6', '6379', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (257, 117, '网络服务', 'haproxy', '', '23300,23306', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (258, 117, '网络服务', 'keepalived', '', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (259, 117, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (260, 117, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (261, 117, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (262, 117, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (263, 117, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (264, 132, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (265, 132, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (266, 132, '网络服务', 'ssh', '7.4p1', '22', '52002', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (267, 132, '搜索引擎', 'elasticsearch', '7.13.2', '9200,9300', '52920,52930', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (268, 132, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (269, 132, '日志、监控与可观测性', 'node-exporter', '', '9100', '52014', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (270, 132, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (271, 132, '前端与用户体验服务', 'zentao', '', '8080', '52880', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (272, 80, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (273, 80, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (274, 80, '网络服务', 'ssh', '7.4p1', '22', '53022', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (275, 80, '前端与用户体验服务', 'formal', '', '8888', '53888', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (276, 80, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000,9001', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (277, 80, '网络服务', 'nginx', '', '80,443', '53080,53443', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (278, 80, '微服务框架与运行时', 'saas-biz', '', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (279, 80, '微服务框架与运行时', 'saas-pub', '', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (280, 80, '安全与身份认证', 'saas-oauth', '', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (281, 80, 'API网关与服务网格', 'saas-gateway', '', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (282, 79, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (283, 79, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (284, 79, '网络服务', 'ssh', '7.4p1', '22', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (285, 79, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000,9001', '38900,38901', '', '2026-04-10 06:13:57', '2026-04-10 06:18:12', NULL);
INSERT INTO `services` VALUES (286, 79, '搜索引擎', 'elasticsearch', '7.13.2', '9200,9300', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (287, 79, '关系型数据库', 'mysql', '8.0.28', '3306', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (288, 79, 'NoSQL数据库', 'mongo', '7.0.0', '27017', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (289, 79, '分布式缓存', 'redis', '6', '6379', '', '', '2026-04-10 06:13:57', '2026-04-10 06:13:57', NULL);
INSERT INTO `services` VALUES (290, 79, '消息队列', 'rabbitmq', 'v2.4.3', '5671,5672,15671,15672', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (291, 79, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848,9848', '', '', '2026-04-10 06:13:57', '2026-04-10 06:17:24', NULL);
INSERT INTO `services` VALUES (292, 68, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (293, 68, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (294, 68, '网络服务', 'ssh', '', '22', '27022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (295, 68, '微服务框架与运行时', 'guan-order', '', '20016', '27016', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (296, 68, '微服务框架与运行时', 'guan-pms', '', '20012', '27012', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (297, 68, '微服务框架与运行时', 'guan-file', '', '20013', '27013', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (298, 68, '安全与身份认证', 'guan-oauth', '', '20011', '27011', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (299, 68, 'API网关与服务网格', 'guan-gateway', '', '20010', '27010', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (300, 68, '微服务框架与运行时', 'guan-merchant', '', '20015', '27015', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (301, 68, '微服务框架与运行时', 'guan-business', '', '20014', '27014', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (302, 68, '微服务框架与运行时', 'seata-server', '1.6.1', '7091,8091,9898', '27791,27891', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (303, 68, '服务发现与配置中心', 'nacos-server', 'v2.4.3', '28848,29848', '27848', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (304, 68, '可视化工具', 'rocketmq-dashboard', '', '8080', '27880', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (305, 68, '消息队列', 'rocketmq-mqbroker', '4.9.4', '9876,10909,10911,10912', '27876,27909,27911,27912', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (306, 68, '消息队列', 'rocketmq-mqnamesrv', '4.9.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (307, 68, '消息队列', 'rabbitmq', 'management', '4369,5671,5672,15671,15672,15691,15692', '27672,27172', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (308, 68, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (309, 68, '分布式缓存', 'redis', '7.4.2', '26379', '27379', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (310, 68, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '29000,29001', '27000,27001', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (311, 68, 'CI/CD流水线', 'jenkins-master', '', '18080,50000', '18027', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (312, 68, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (313, 68, '关系型数据库', 'mysql', '8.0.41', '23306', '27306', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (314, 68, '网络服务', 'nginx', '1.20.1', '80,443', '27080,27443', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (315, 69, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (316, 69, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (317, 69, '网络服务', 'ssh', '', '22', '14022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (318, 69, '可视化工具', 'kibana', '7.17.18', '5601', '28561', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (319, 69, '搜索引擎', 'elasticsearch', '7.17.18', '9200,9300', '28920,28930', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (320, 69, '关系型数据库', 'mysql', '8.0.41-debian', '13306', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (321, 69, '关系型数据库', 'mysql', '8.0.41-debian', '3306', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (322, 69, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '9113', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (323, 69, '日志、监控与可观测性', 'node-exporter', 'latest', '9100', '9128', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (324, 69, '网络服务', 'nginx', '1.20.1', '80,18080', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (325, 70, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (326, 70, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (327, 70, '网络服务', 'ssh', '', '22', '15022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (328, 70, '微服务框架与运行时', 'dj-server', '', '20000', '20031', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (329, 70, '微服务框架与运行时', 'clsp-file', '', '31010', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (330, 70, '微服务框架与运行时', 'clsp-visual-display', '', '31005', '31005', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (331, 70, '微服务框架与运行时', 'clsp-order', '', '31006', '31006', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (332, 70, '微服务框架与运行时', 'clsp-merchant', '', '31009', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (333, 70, '安全与身份认证', 'clsp-iam', '', '31004', '31004', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (334, 70, '安全与身份认证', 'clsp-oauth', '', '31001', '31001', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (335, 70, 'API网关与服务网格', 'clsp-gateway', '', '31000', '31000', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (336, 70, '微服务框架与运行时', 'seata-server', '1.6.1', '3692,7091,8091,9898', '3692', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (337, 70, '前端与用户体验服务', 'clsp-swagger', '', '31002', '31002', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (338, 70, 'API网关与服务网格', 'tdgateway', '', '7777', '31777', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (339, 70, '微服务框架与运行时', 'tdums', '', '31006', '31103', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (340, 70, '安全与身份认证', 'tdoauth', '', '31006', '31101', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (341, 70, '微服务框架与运行时', 'tdbup', '', '10102', '31102', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (342, 70, '日志、监控与可观测性', 'sentinel-dashboard', '', '8858,8989', '31989', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (343, 70, '可视化工具', 'kafka-ui', '', '8080', '20080', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (344, 70, '消息队列', 'cp-kafka', '', '9092', '20092', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (345, 70, '服务发现与配置中心', 'zookeeper', '', '2181,2888,3888', '2181,2888,3888', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (346, 70, '消息队列', 'rabbitmq', 'management', '5671,5672,4369,15671,15672,15691,15692', '20672,20156', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (347, 70, '关系型数据库', 'mysql', '8.0.41', '23306', '23331', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (348, 70, '关系型数据库', 'mysql', '8.0.41', '13306', '13331', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (349, 70, '关系型数据库', 'mysql', '8.0.41', '3306', '31306', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (350, 70, 'NoSQL数据库', 'mongo', '4.0.10', '27017', '13117', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (351, 70, '分布式缓存', 'redis', '', '16379', '16331', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (352, 70, '分布式缓存', 'redis', '', '6379', '63792', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (353, 70, '分布式缓存', 'redis', '', '26379', '26331', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (354, 70, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '19000,19001', '31190,31191', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (355, 70, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '29000,29001', '29031,29131', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (356, 70, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '9000,9001', '20000,20001', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (357, 70, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848,9848,9849', '18848,19848,19849', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (358, 70, '网络服务', 'nginx', '1.20.1', '80,8098,8099,10080,19002,20080,22080,31008,33080', '13180,28031,23180,31080,31443,31098,31099,31008,33080,33081', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (359, 70, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (360, 71, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (361, 71, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (362, 71, '网络服务', 'ssh', '', '22', '30022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (363, 71, '微服务框架与运行时', 'park-file', '', '10102', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (364, 71, '微服务框架与运行时', 'park-ums', '', '10104', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (365, 71, '安全与身份认证', 'park-oauth', '', '10103', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (366, 71, 'API网关与服务网格', 'park-gateway', '', '10100', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (367, 71, '微服务框架与运行时', 'park-bup', '', '10101', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (368, 71, '微服务框架与运行时', 'tlxx-modules-system', '', '9016', '30916', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (369, 71, 'API网关与服务网格', 'tlxx-gateway', '', '9010', '30910', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (370, 71, '微服务框架与运行时', 'tlxx-modules-annex', '', '9012', '30912', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (371, 71, '微服务框架与运行时', 'tlxx-modules-magic-api', '', '9014', '30914', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (372, 71, '微服务框架与运行时', 'tlxx-modules-monitor', '', '9011', '30911', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (373, 71, '微服务框架与运行时', 'tlxx-modules-cms', '', '9018', '30918', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (374, 71, '微服务框架与运行时', 'tlxx_cms', '', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (375, 71, '微服务框架与运行时', 'seata-server', '1.6.1', '3291,27091,29898', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (376, 71, '微服务框架与运行时', 'seata-server', '1.6.1', '3191,17091,19898', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (377, 71, '微服务框架与运行时', 'seata-server', '1.5.2', '7091,8091', '30791,30891', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (378, 71, '分布式缓存', 'redis', '6.2.6', '26379', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (379, 71, '分布式缓存', 'redis', '6.2.6', '16379', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (380, 71, '分布式缓存', 'redis', '6.2.6', '6379', '30379', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (381, 71, '消息队列', 'rabbitmq', 'management', '15691,15692,4169,1671,1672,11671', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (382, 71, '消息队列', 'rabbitmq', 'management', '4369,15691,4269,2671,2672,12671,12672,22672', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (383, 71, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (384, 71, 'CI/CD流水线', 'jenkins-slave', '', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (385, 71, '存储服务', 'registry', '', '5000', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (386, 71, '搜索引擎', 'elasticsearch', '7.12.1', '9200,9300', '30920,30930', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (387, 71, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '29000,29001', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (388, 71, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '19000,19001', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (389, 71, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '9000,9001', '30900', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (390, 71, 'NoSQL数据库', 'mongo', '4.0.10', '27017', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (391, 71, '关系型数据库', 'mysql', '8.0.41-debian', '3306', '30306', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (392, 71, '关系型数据库', 'mysql', '8.0.41-debian', '23306', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (393, 71, '关系型数据库', 'mysql', '8.0.41-debian', '13306', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (394, 71, '网络服务', 'nginx', '1.18.0', '80,10003,10004,10005', '19080,30103,30104,30105', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (395, 71, '服务发现与配置中心', 'nacos', 'v1.4.2', '8848,9848', '30848', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (396, 71, '服务发现与配置中心', 'nacos', 'v2.4.3', '18848,19848,19849', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (397, 71, '服务发现与配置中心', 'nacos', 'v2.4.3', '28848,29848,29849', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (398, 72, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (399, 72, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (400, 72, '网络服务', 'ssh', '', '22', '29022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (401, 72, '搜索引擎', 'elasticsearch', '7.17.18', '9200,9300', '29920,29930', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (402, 72, '关系型数据库', 'mysql', '8.0.41', '3306', '33306', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (403, 72, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '9000,9001', '59000,59001', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (404, 72, '分布式缓存', 'redis', '', '6379', '56379', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (405, 72, '服务发现与配置中心', 'nacos', 'v1.4.2', '8848,9848', '58848', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (406, 72, '消息队列', 'rabbitmq', 'management', '5671,5672,4369,15671,15672,15691,15692,25672', '55672,56725', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (407, 73, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (408, 73, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (409, 73, '网络服务', 'ssh', '', '22', '18022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (410, 73, '微服务框架与运行时', 'vehicle-bup', '', '11112', '32112', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (411, 73, '微服务框架与运行时', 'vehicle-ums', '', '11113', '32113', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (412, 73, '安全与身份认证', 'vehicle-oauth', '', '11111', '32111', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (413, 73, '微服务框架与运行时', 'attractinv', '', '9002', '9002', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (414, 73, 'API网关与服务网格', 'saas-gateway', '', '8989', '32989', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (415, 73, 'API网关与服务网格', 'vehicle-gateway', '', '9999', '29999', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (416, 73, 'API网关与服务网格', 'saas-gateway', '', '10200', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (417, 73, '安全与身份认证', 'saas-oauth', '', '10103', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (418, 73, '微服务框架与运行时', 'saas-pub', '', '10101', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (419, 73, '微服务框架与运行时', 'saas-file', '', '10102', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (420, 73, '微服务框架与运行时', 'saas-biz', '', '10204', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (421, 73, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (422, 73, '网络服务', 'nginx', '1.20.1', '80,19002', '32080,19002', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (423, 73, '关系型数据库', 'mysql', '', '3306', '25306', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (424, 73, '分布式缓存', 'redis', '', '6379', '23379', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (425, 73, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '9000,9001', '23000', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (426, 74, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (427, 74, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (428, 74, '网络服务', 'ssh', '', '22', '19022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (429, 74, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (430, 74, '分布式缓存', 'redis', '', '6379', '26379', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (431, 74, '关系型数据库', 'mysql', '', '3306', '23306', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (432, 74, '存储服务', 'minio', '', '9000,9001', '39000,9001', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (433, 74, '服务发现与配置中心', 'nacos', '', '8848,9848', '28848', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (434, 74, '消息队列', 'rabbitmq', '', '5671,5672,15671,15672,15691,15692,25672', '33672', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (435, 74, '网络服务', 'nginx', '', '80', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (436, 75, '容器编排', 'docker', '28.0.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (437, 75, '容器编排', 'docker-compose', 'v2.34.0', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (438, 75, '网络服务', 'ssh', '', '22', '20022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (439, 75, '安全与身份认证', 'oa-oauth', '', '11111', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (440, 75, '微服务框架与运行时', 'oa-project', '', '10089', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (441, 75, 'API网关与服务网格', 'oa-gateway', '', '9999', '22999', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (442, 75, '微服务框架与运行时', 'oa-oa', '', '10087', '10087', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (443, 75, '微服务框架与运行时', 'oa-meeting', '', '10086', '10086', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (444, 75, '微服务框架与运行时', 'oa-asset', '', '10088', '10088', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (445, 75, '微服务框架与运行时', 'oa-camunda', '', '10076', '10076', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (446, 75, '微服务框架与运行时', 'oa-file', '', '10100', '10100', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (447, 75, '微服务框架与运行时', 'oa-bup', '', '11112', '11112', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (448, 75, '微服务框架与运行时', 'guan-file', '', '20013', '20013', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (449, 75, '微服务框架与运行时', 'guan-order', '', '20016', '20016', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (450, 75, '微服务框架与运行时', 'guan-merchant', '', '20015', '20015', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (451, 75, '微服务框架与运行时', 'guan-business', '', '20014', '20014', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (452, 75, '安全与身份认证', 'guan-oauth', '', '20011', '20011', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (453, 75, 'API网关与服务网格', 'guan-gateway', '', '20010', '20010', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (454, 75, '微服务框架与运行时', 'guan-pms', '', '20012', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (455, 75, '微服务框架与运行时', 'dc-pay', '', '38666', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (456, 75, '微服务框架与运行时', 'seata-server', '1.6.1', '3691,7091,9898,8091', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (457, 75, '服务发现与配置中心', 'nacos', 'v2.4.3', '28848,29848,29849', '20008', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (458, 75, '消息队列', 'rabbitmq', 'management', '5671,5672,4369,15671,15672,15691,25672', '36672,36172', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (459, 75, '消息队列', 'rabbitmq', 'management', '37672,30672,37671,35672,37673', '35672,30672', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (460, 75, '搜索引擎', 'elasticsearch', '7.13.2', '9200,9300', '36920', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (461, 75, 'NoSQL数据库', 'mongo', '4.0.10', '37107', '37107', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (462, 75, '分布式缓存', 'redis', '', '36379', '21379', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (463, 75, '分布式缓存', 'redis', '', '26379', '20009', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (464, 75, '关系型数据库', 'mysql', '8.0.41', '33306', '21306', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (465, 75, '关系型数据库', 'mysql', '8.0.41', '23306', '20006', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (466, 75, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '39000,39001', '21000,39001', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (467, 75, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '29000,29001', '29000,29001', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (468, 75, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (469, 75, '网络服务', 'nginx', '1.20.1', '80,443,30080', '22080,22443,21080', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (470, 76, '容器编排', 'docker', '28.0.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (471, 76, '容器编排', 'docker-compose', 'v2.34.0', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (472, 76, '网络服务', 'ssh', '', '22', '21022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (473, 76, '搜索引擎', 'elasticsearch', '7.13.2', '9201,9301', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (474, 76, '搜索引擎', 'elasticsearch', '7.13.2', '9200,9300', '49200', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (475, 76, '日志、监控与可观测性', 'node-exporter', '', '9100', '9100', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (476, 76, '存储服务', 'minio', 'RELEASE.2024-09-09T16-59-28Z', '9000,9001', '24000,24001', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (477, 76, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848,9848', '48848', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (478, 76, '关系型数据库', 'mysql', '8.0.41', '3306', '43306', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (479, 76, '分布式缓存', 'redis', '', '6379', '46379', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (480, 76, '日志、监控与可观测性', 'redis-exporter', '', '9121', '9121', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (481, 76, '日志、监控与可观测性', 'mysqld-exporter', '', '9104', '9104', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (482, 76, '消息队列', 'rabbitmq', 'management', '5671,5672,15671,15672,15691,15692,25672', '24672,24156', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (483, 77, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (484, 77, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (485, 77, '网络服务', 'ssh', '', '22', '22022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (486, 77, '微服务框架与运行时', 'eps-biz', '', '10014,10026', '10014,10026', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (487, 77, 'API网关与服务网格', 'eps-gateway', '', '9999', '35999', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (488, 77, '安全与身份认证', 'eps-oauth', '', '10011', '10011', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (489, 77, '微服务框架与运行时', 'eps-pms', '', '10012', '10012', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (490, 77, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (491, 77, '网络服务', 'nginx', '1.20.1', '80', '16080', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (492, 78, '容器编排', 'docker', '26.1.4', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (493, 78, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (494, 78, '网络服务', 'ssh', '', '22', '51022', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (495, 78, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '9000,9001', '19000,19001', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (496, 78, 'NoSQL数据库', 'mongo', '4.0.10', '27017', '57037', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (497, 78, '搜索引擎', 'elasticsearch', '4.0.10', '9200,9300', '19200', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (498, 78, '可视化工具', 'kafka-ui', '', '8000', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (499, 78, '消息队列', 'cp-kafka', '', '9092', '9092', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (500, 78, '消息队列', 'rabbitmq', 'management', '5671,5672,4369,15671,15672,15691,15692,25672', '51672', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (501, 78, '服务发现与配置中心', 'zookeeper', '', '2181,2888,3888', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (502, 78, '流计算', 'flink', '1.13.2', '6123,8081,15005', '28081,15005', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (503, 78, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848,9848', '51848', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (504, 78, '分布式缓存', 'redis', '', '6379', '16379', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (505, 78, '关系型数据库', 'mysql', '8.0.41', '3306', '13306', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);
INSERT INTO `services` VALUES (506, 78, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', '2026-04-10 06:43:27', '2026-04-10 06:43:27', NULL);

-- ----------------------------
-- Table structure for ssl_certificates
-- ----------------------------
DROP TABLE IF EXISTS `ssl_certificates`;
CREATE TABLE `ssl_certificates`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `domain` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '域名',
  `cert_type` tinyint NULL DEFAULT 0 COMMENT '证书类型 0:自动检测 1:手动录入 2:阿里云证书',
  `issuer` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '颁发机构',
  `cert_generate_time` datetime NULL DEFAULT NULL COMMENT '证书生成时间',
  `cert_valid_days` int NULL DEFAULT NULL COMMENT '有效期天数',
  `cert_expire_time` datetime NULL DEFAULT NULL COMMENT '证书到期时间',
  `remaining_days` int NULL DEFAULT NULL COMMENT '剩余天数',
  `brand` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '品牌',
  `cost` decimal(10, 2) NULL DEFAULT NULL COMMENT '费用',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '正常' COMMENT '状态',
  `last_check_time` datetime NULL DEFAULT NULL COMMENT '最后检测时间',
  `last_notify_time` datetime NULL DEFAULT NULL COMMENT '最后通知时间',
  `notify_status` tinyint NULL DEFAULT 0 COMMENT '通知状态 0:未通知 1:已通知',
  `source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'manual' COMMENT '来源 manual/auto/aliyun',
  `aliyun_account_id` int NULL DEFAULT NULL COMMENT '关联阿里云账户ID',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `cert_file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `key_file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `has_cert_file` tinyint NULL DEFAULT 0,
  `project_id` int NULL DEFAULT NULL COMMENT '所属项目ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_domain`(`domain` ASC) USING BTREE,
  INDEX `idx_cert_type`(`cert_type` ASC) USING BTREE,
  INDEX `idx_expire_time`(`cert_expire_time` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 68 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'SSL证书管理表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ssl_certificates
-- ----------------------------
INSERT INTO `ssl_certificates` VALUES (53, 'opm.pepsikey.online', 2, 'DigiCert Inc', '2026-04-02 08:00:00', 89, '2026-07-01 07:59:59', 86, NULL, NULL, '1', '2026-04-10 06:38:36', NULL, 0, 'aliyun', 1, NULL, '2026-04-05 15:07:20', '2026-04-10 06:38:36', '/app/app/uploads/certs/53/opm.pepsikey.online.pem', '/app/app/uploads/certs/53/opm.pepsikey.online.key', 1, NULL);
INSERT INTO `ssl_certificates` VALUES (54, 'cdb.huazsz.com', 2, 'DigiCert Inc', '2026-03-16 00:00:00', 89, '2026-06-13 23:59:59', 65, NULL, NULL, '1', '2026-04-10 06:38:26', NULL, 0, 'aliyun', 3, NULL, '2026-04-05 15:07:20', '2026-04-10 06:38:26', '/app/app/uploads/certs/54/cdb.huazsz.com.pem', '/app/app/uploads/certs/54/cdb.huazsz.com.key', 1, NULL);
INSERT INTO `ssl_certificates` VALUES (55, 'sdc.sjzctg.com', 2, 'DigiCert Inc', '2026-03-31 08:00:00', 89, '2026-06-29 07:59:59', 81, NULL, NULL, '1', NULL, NULL, 0, 'aliyun', 2, NULL, '2026-04-05 15:07:20', '2026-04-08 17:52:25', '/app/app/uploads/certs/55/sdc.sjzctg.com.pem', '/app/app/uploads/certs/55/sdc.sjzctg.com.key', 1, 3);
INSERT INTO `ssl_certificates` VALUES (56, 'h5.sjzctg.com', 2, 'DigiCert Inc', '2026-03-31 08:00:00', 89, '2026-06-29 07:59:59', 81, NULL, NULL, '1', NULL, NULL, 0, 'aliyun', 2, NULL, '2026-04-05 15:07:20', '2026-04-08 17:52:41', '/app/app/uploads/certs/56/h5.sjzctg.com.pem', '/app/app/uploads/certs/56/h5.sjzctg.com.key', 1, 3);
INSERT INTO `ssl_certificates` VALUES (57, 'test.pepsikey.online', 2, 'DigiCert Inc', '2026-03-21 08:00:00', 89, '2026-06-19 07:59:59', 75, NULL, NULL, '1', NULL, NULL, 0, 'aliyun', 1, NULL, '2026-04-05 15:07:20', '2026-04-05 15:07:20', '/app/app/uploads/certs/57/test.pepsikey.online.pem', '/app/app/uploads/certs/57/test.pepsikey.online.key', 1, NULL);
INSERT INTO `ssl_certificates` VALUES (58, 'web.huazsz.com', 2, 'Beijing Xinchacha Credit Management Co., Ltd.', '2025-11-11 09:02:06', 394, '2026-12-11 09:02:05', 247, NULL, NULL, '1', '2026-04-08 18:20:21', NULL, 0, 'aliyun', 3, NULL, '2026-04-05 15:07:20', '2026-04-08 18:20:21', '/app/app/uploads/certs/58/web.huazsz.com.pem', '/app/app/uploads/certs/58/web.huazsz.com.key', 1, NULL);
INSERT INTO `ssl_certificates` VALUES (59, 'hytest.sjzctg.com', 2, 'DigiCert Inc', '2026-03-30 08:00:00', 89, '2026-06-28 07:59:59', 80, NULL, NULL, '1', NULL, NULL, 0, 'aliyun', 2, NULL, '2026-04-05 15:07:20', '2026-04-08 17:52:52', '/app/app/uploads/certs/59/hytest.sjzctg.com.pem', '/app/app/uploads/certs/59/hytest.sjzctg.com.key', 1, 7);
INSERT INTO `ssl_certificates` VALUES (60, 'openclaw.pepsikey.online', 2, 'DigiCert Inc', '2026-03-10 00:00:00', 89, '2026-06-07 23:59:59', 59, NULL, NULL, '1', '2026-04-10 06:38:24', NULL, 0, 'aliyun', 1, NULL, '2026-04-05 15:07:20', '2026-04-10 06:38:24', '/app/app/uploads/certs/60/openclaw.pepsikey.online.pem', '/app/app/uploads/certs/60/openclaw.pepsikey.online.key', 1, NULL);
INSERT INTO `ssl_certificates` VALUES (61, 'www.msjszbpt.com', 2, 'DigiCert Inc', '2026-03-20 08:00:00', 89, '2026-06-18 07:59:59', 70, NULL, NULL, '1', NULL, NULL, 0, 'aliyun', 2, NULL, '2026-04-05 15:07:20', '2026-04-08 17:53:05', '/app/app/uploads/certs/61/www.msjszbpt.com.pem', '/app/app/uploads/certs/61/www.msjszbpt.com.key', 1, 4);
INSERT INTO `ssl_certificates` VALUES (62, 'bm.msjszbpt.com', 2, 'DigiCert Inc', '2026-03-20 08:00:00', 89, '2026-06-18 07:59:59', 70, NULL, NULL, '1', NULL, NULL, 0, 'aliyun', 2, NULL, '2026-04-05 15:07:21', '2026-04-08 17:53:12', '/app/app/uploads/certs/62/bm.msjszbpt.com.pem', '/app/app/uploads/certs/62/bm.msjszbpt.com.key', 1, 4);
INSERT INTO `ssl_certificates` VALUES (63, 'djymjsw.djymjsw.com', 2, 'DigiCert Inc', '2026-03-17 08:00:00', 89, '2026-06-15 07:59:59', 71, NULL, NULL, '1', '2026-04-10 06:39:08', NULL, 0, 'aliyun', 2, NULL, '2026-04-05 15:07:21', '2026-04-10 06:39:08', '/app/app/uploads/certs/63/djymjsw.djymjsw.com.pem', '/app/app/uploads/certs/63/djymjsw.djymjsw.com.key', 1, NULL);
INSERT INTO `ssl_certificates` VALUES (66, 'hy.sjzctg.com', 0, 'Beijing Xinchacha Credit Management Co., Ltd.', '2025-11-04 06:30:51', 394, '2026-12-04 06:30:50', 238, '', 0.00, '1', '2026-04-10 08:00:00', NULL, 0, 'manual', NULL, '', '2026-04-08 18:17:00', '2026-04-10 08:00:00', NULL, NULL, 0, 7);

-- ----------------------------
-- Table structure for task_logs
-- ----------------------------
DROP TABLE IF EXISTS `task_logs`;
CREATE TABLE `task_logs`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL COMMENT '任务ID',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '执行状态: pending/running/success/failed',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `output` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '执行输出',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '错误信息',
  `server_id` int NULL DEFAULT NULL COMMENT '执行服务器ID',
  `triggered_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '触发方式: schedule/manual',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  CONSTRAINT `task_logs_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `scheduled_tasks` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务执行日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of task_logs
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码哈希',
  `display_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '显示名称',
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'operator' COMMENT '角色: admin/operator/viewer',
  `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否激活',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `password_changed_at` datetime NULL DEFAULT NULL COMMENT '密码修改时间，早于该时间的 JWT 作废',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (30, 'admin', '$2b$12$EdHpY96uGEnXQfkVrIeqyeLOuG1xDubku.qK0Le25APC8guCNkR.y', '系统管理员', 'admin', 1, '2026-04-03 05:58:17', '2026-04-07 08:26:09', '2026-04-07 08:26:09');

SET FOREIGN_KEY_CHECKS = 1;
