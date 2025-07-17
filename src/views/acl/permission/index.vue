<template>
  <div class="app-container">
    <!-- 权限树形表格展示，参考产品分类管理页面 -->
    <el-card>
      <template #header>
        <div class="card-header">
          <span>权限管理</span>
          <el-button type="primary" @click="openAddDialog">新增权限</el-button>
        </div>
      </template>
      <!-- 树形结构表格，children字段为子权限 -->
      <el-table :data="roleList" border style="width: 100%" row-key="Id" :tree-props="{ children: 'Children' }">
        <!-- 权限名称列，靠左显示 -->
        <el-table-column prop="Name" label="权限名称" min-width="200" align="left" show-overflow-tooltip />
        <!-- 新增描述说明列 -->
        <el-table-column prop="Description" label="描述说明" min-width="200" align="left" show-overflow-tooltip />
        <!-- 权限值列 -->
        <el-table-column prop="Code" label="权限值" min-width="120" show-overflow-tooltip />
        <!-- 操作列 -->
        <el-table-column label="操作" width="260">
          <template #default="{ row }">
            <!-- 仅1、2级权限显示添加子权限按钮，3级不显示 -->
            <el-button v-if="(row.Type ?? row.level) < 3" type="primary" link @click="openAddDialog(row)">添加子权限</el-button>
            <el-button type="primary" link @click="openEditDialog(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 权限编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogType === 'add' ? '新增权限' : '编辑权限'" width="600px">
      <el-form :model="form" ref="formRef" label-width="100px">
        <!-- 仅添加2级、3级权限时显示上级权限，1级权限不显示 -->
        <el-form-item label="上级权限" v-if="dialogType === 'add' && form.ParentId && (form.Type === 2 || form.Type === 3)">
          <el-input :value="parentName" disabled />
        </el-form-item>
        <el-form-item label="权限名称" prop="Name">
          <el-input v-model="form.Name" placeholder="请输入权限名称" />
        </el-form-item>
        <el-form-item label="权限值" prop="Code">
          <el-input v-model="form.Code" placeholder="请输入权限值" />
        </el-form-item>
        <el-form-item label="描述说明" prop="Description">
          <el-input v-model="form.Description" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSave">确定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang='ts'>
import { ref, reactive, onMounted, computed } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
// 导入菜单（权限）查询接口
import { reqMenuInfo } from '@/api/acl/menu';
import { reqUpdatePermission } from '@/api/acl/menu'; // 新增：导入修改权限API
import { reqAddPermission } from '@/api/acl/menu'; // 新增：导入新增权限API
import { reqDeletePermission } from '@/api/acl/menu'; // 新增：导入删除权限API

// 权限树形数据
const roleList = ref<any[]>([]); // 权限树形结构数据

// 对话框相关
const dialogVisible = ref(false);
const dialogType = ref<'add' | 'edit'>('add');
const formRef = ref();

// 权限表单
const form = reactive({
  Id: undefined,
  Name: '',
  Code: '',
  Description: '', // 新增描述字段
  ParentId: null,
  Type: 1 // 新增层级字段，默认为1级
});

// 计算属性：显示父权限名称
const parentName = computed(() => {
  if (form.ParentId) {
    function findName(list: any[], id: number | string): string | undefined {
      for (const item of list) {
        if (item.Id === id) return item.Name;
        if (item.Children && item.Children.length) {
          const found = findName(item.Children, id);
          if (found) return found;
        }
      }
      return undefined;
    }
    return findName(roleList.value, form.ParentId) || '';
  }
  return '';
});

// 获取权限树形数据
const getRoleList = async () => {
  try {
    // 假设接口返回树形结构：[{ Id, Name, Code, Children: [...] }]
    const res = await reqMenuInfo();
    roleList.value = Array.isArray(res.data) ? res.data : [];
  } catch (error) {
    ElMessage.error('获取权限数据失败');
    console.error('获取权限失败:', error);
    roleList.value = [];
  }
};

// 新增权限
const openAddDialog = (row?: any) => {
  dialogType.value = 'add';
  dialogVisible.value = true;
  if (row) {
    // 添加子权限，层级+1
    form.Id = undefined;
    form.Name = '';
    form.Code = '';
    form.Description = '';
    form.ParentId = row.Id;
    form.Type = (row.Type ?? row.level) + 1;
  } else {
    // 添加一级权限
    form.Id = undefined;
    form.Name = '';
    form.Code = '';
    form.Description = '';
    form.ParentId = null;
    form.Type = 1;
  }
};

// 编辑权限
const openEditDialog = (row: any) => {
  dialogType.value = 'edit';
  dialogVisible.value = true;
  form.Id = row.Id;
  form.Name = row.Name;
  form.Code = row.Code;
  form.Description = row.Description;
  form.ParentId = row.ParentId ?? null;
  form.Type = row.Type ?? 1;
};

// 删除权限
const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除权限“${row.Name}”吗？${row.Children && row.Children.length > 0 ? '删除后将同时删除其下所有子权限！' : ''}`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    );
    // 调用删除权限接口
    await reqDeletePermission(row.Id);
    ElMessage.success('删除成功');
    getRoleList();
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败');
      console.error('删除权限错误:', error);
    }
  }
};

// 保存权限信息
const handleSave = async () => {
  if (!formRef.value) return;
  try {
    if (dialogType.value === 'edit') {
      await reqUpdatePermission({
        Id: form.Id,
        Name: form.Name,
        Code: form.Code,
        Description: form.Description,
        Type: form.Type
      });
      ElMessage.success('更新成功');
    } else {
      // 新增权限
      await reqAddPermission({
        Name: form.Name,
        Code: form.Code,
        Description: form.Description,
        ParentId: form.ParentId,
        Type: form.Type
      });
      ElMessage.success('新增成功');
    }
    dialogVisible.value = false;
    getRoleList();
  } catch (error) {
    ElMessage.error(dialogType.value === 'add' ? '新增失败' : '更新失败');
    console.error('保存权限信息错误:', error);
  }
};

// 初始化加载数据
onMounted(() => {
  getRoleList();
});

import { getCurrentInstance } from 'vue';

const tableRef = ref();

const handleRowClick = (row: any, column: any, event: MouseEvent) => {
  // 只对有子节点的行处理
  if (row.Children && row.Children.length > 0) {
    // 通过ref获取el-table实例，调用toggleRowExpansion
    tableRef.value.store.toggleRowExpanded(row);
  }
};
</script>

<style scoped>
.app-container {
  padding: 20px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.dialog-footer {
  text-align: right;
}
</style>