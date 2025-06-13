<template>
  <div class="perm-manage">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>权限管理</span>
          <el-button type="primary" @click="handleAdd">新增权限</el-button>
        </div>
      </template>
      <el-table
        :data="tableData"
        row-key="id"
        border
        default-expand-all
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
      >
        <el-table-column prop="name" label="权限名称" />
        <el-table-column prop="code" label="权限编码" />
        <el-table-column prop="type" label="类型" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.type === 1 ? 'success' : 'warning'">
              {{ scope.row.type === 1 ? '菜单' : '按钮' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="path" label="路由路径" />
        <el-table-column prop="component" label="组件路径" />
        <el-table-column prop="icon" label="图标" width="100">
          <template #default="scope">
            <el-icon v-if="scope.row.icon">
              <component :is="scope.row.icon" />
            </el-icon>
          </template>
        </el-table-column>
        <el-table-column prop="sort" label="排序" width="80" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button type="primary" link @click="handleAdd(scope.row)">新增</el-button>
            <el-button type="primary" link @click="handleEdit(scope.row)">编辑</el-button>
            <el-button type="primary" link @click="handleDelete(scope.row)">删除</el-button>
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
    name: '系统管理',
    code: 'system',
    type: 1,
    path: '/system',
    component: 'Layout',
    icon: 'Setting',
    sort: 1,
    children: [
      {
        id: 2,
        name: '用户管理',
        code: 'system:user',
        type: 1,
        path: '/system/user',
        component: 'system/user/index',
        icon: 'User',
        sort: 1
      },
      {
        id: 3,
        name: '角色管理',
        code: 'system:role',
        type: 1,
        path: '/system/role',
        component: 'system/role/index',
        icon: 'UserFilled',
        sort: 2
      },
      {
        id: 4,
        name: '权限管理',
        code: 'system:perm',
        type: 1,
        path: '/system/perm',
        component: 'system/perm/index',
        icon: 'Menu',
        sort: 3
      }
    ]
  }
])

// 新增权限
const handleAdd = (row?: any) => {
  console.log('新增权限', row)
}

// 编辑权限
const handleEdit = (row: any) => {
  console.log('编辑权限', row)
}

// 删除权限
const handleDelete = (row: any) => {
  console.log('删除权限', row)
}
</script>

<style scoped>
.perm-manage {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style> 