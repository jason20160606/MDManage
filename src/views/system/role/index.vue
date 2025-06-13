<template>
  <div class="role-manage">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>角色管理</span>
          <el-button type="primary" @click="handleAdd">新增角色</el-button>
        </div>
      </template>
      <el-table :data="tableData" style="width: 100%">
        <el-table-column prop="roleName" label="角色名称" />
        <el-table-column prop="roleCode" label="角色编码" />
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="status" label="状态">
          <template #default="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
              {{ scope.row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" />
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button type="primary" link @click="handleEdit(scope.row)">编辑</el-button>
            <el-button type="primary" link @click="handleDelete(scope.row)">删除</el-button>
            <el-button type="primary" link @click="handlePermission(scope.row)">权限设置</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// 表格数据
const tableData = ref([
  {
    id: 1,
    roleName: '超级管理员',
    roleCode: 'admin',
    description: '系统最高权限',
    status: 1,
    createTime: '2024-03-20 10:00:00'
  }
])

// 新增角色
const handleAdd = () => {
  console.log('新增角色')
}

// 编辑角色
const handleEdit = (row: any) => {
  console.log('编辑角色', row)
}

// 删除角色
const handleDelete = (row: any) => {
  console.log('删除角色', row)
}

// 权限设置
const handlePermission = (row: any) => {
  console.log('权限设置', row)
}
</script>

<style scoped>
.role-manage {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style> 