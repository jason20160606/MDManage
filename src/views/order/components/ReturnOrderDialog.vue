<template>
  <el-dialog v-model="dialogVisible" title="订单退货" width="520px" @closed="resetForm">
    <el-alert
      type="warning"
      :closable="false"
      show-icon
      title="整单退货，不可撤销"
      description="将全额返还经销商额度、按已发数量退回发货仓库存，并冲销该单运费/差价应收行（已结算的生成红字行抵扣下期）。"
      style="margin-bottom: 16px"
    />
    <el-descriptions :column="1" border size="small">
      <el-descriptions-item label="订单编号">{{ order?.OrderNo || '—' }}</el-descriptions-item>
      <el-descriptions-item label="经销商">{{ order?.DealerName || '—' }}</el-descriptions-item>
      <el-descriptions-item label="已发箱数">{{ fmtQty(Number(order?.ShippedQty || 0)) }}</el-descriptions-item>
    </el-descriptions>
    <el-form ref="formRef" :model="form" :rules="rules" label-width="90px" style="margin-top: 16px">
      <el-form-item label="退货原因" prop="Reason">
        <el-select v-model="form.Reason" placeholder="请选择退货原因" style="width: 100%">
          <el-option v-for="r in reasons" :key="r" :label="r" :value="r" />
        </el-select>
      </el-form-item>
      <el-form-item label="备注" prop="Remark">
        <el-input v-model="form.Remark" type="textarea" :rows="2" placeholder="选填，如客户沟通记录、退回物流单号" />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="danger" :loading="submitting" @click="submit">确认退货</el-button>
    </template>
  </el-dialog>

  <el-dialog v-model="resultVisible" title="退货结果" width="720px">
    <el-result icon="success" title="退货成功" :sub-title="result?.Message || ''" />
    <el-descriptions :column="2" border size="small">
      <el-descriptions-item label="退货单号">{{ result?.ReturnNo || '—' }}</el-descriptions-item>
      <el-descriptions-item label="订单编号">{{ result?.OrderNo || '—' }}</el-descriptions-item>
      <el-descriptions-item label="经销商">{{ result?.DealerName || '—' }}</el-descriptions-item>
      <el-descriptions-item label="状态变化">{{ statusText(result?.BeforeStatus) }} → {{ statusText(result?.AfterStatus) }}</el-descriptions-item>
      <el-descriptions-item label="退回箱数">{{ fmtQty(Number(result?.TotalQty || 0)) }}</el-descriptions-item>
      <el-descriptions-item label="返还额度">{{ fmtQty(Number(result?.QuotaRestored || 0)) }} 箱</el-descriptions-item>
      <el-descriptions-item label="经销商额度">{{ fmtQty(Number(result?.BeforeDealerQuota || 0)) }} → {{ fmtQty(Number(result?.AfterDealerQuota || 0)) }}</el-descriptions-item>
      <el-descriptions-item label="运费冲销">¥{{ Number(result?.FreightReversed || 0).toFixed(2) }}</el-descriptions-item>
      <el-descriptions-item label="差价冲销">¥{{ Number(result?.PriceDiffReversed || 0).toFixed(2) }}</el-descriptions-item>
      <el-descriptions-item label="运费余额">{{ Number(result?.BeforeFreight || 0).toFixed(2) }} → {{ Number(result?.AfterFreight || 0).toFixed(2) }}</el-descriptions-item>
      <el-descriptions-item label="差价余额">{{ Number(result?.BeforePriceDiff || 0).toFixed(2) }} → {{ Number(result?.AfterPriceDiff || 0).toFixed(2) }}</el-descriptions-item>
      <el-descriptions-item label="操作人">{{ result?.CreatedByName || '—' }}</el-descriptions-item>
      <el-descriptions-item label="退货时间">{{ formatDate(result?.CreatedAt) }}</el-descriptions-item>
    </el-descriptions>

    <div v-if="result?.QuotaChanges?.length" class="section">
      <div class="section-title">额度返还明细</div>
      <el-table :data="result.QuotaChanges" size="small" border>
        <el-table-column prop="QuotaName" label="额度类型" />
        <el-table-column prop="BeforeAmount" label="返还前" align="right" />
        <el-table-column prop="ChangeQuantity" label="返还数量" align="right" />
        <el-table-column prop="AfterAmount" label="返还后" align="right" />
      </el-table>
    </div>
    <div v-if="result?.StockChanges?.length" class="section">
      <div class="section-title">库存回退明细</div>
      <el-table :data="result.StockChanges" size="small" border>
        <el-table-column prop="ProductName" label="商品" min-width="160" show-overflow-tooltip />
        <el-table-column prop="Action" label="动作" width="100" />
        <el-table-column prop="Quantity" label="数量" width="90" align="right" />
        <el-table-column prop="WarehouseName" label="仓库" min-width="140" show-overflow-tooltip />
      </el-table>
    </div>

    <template #footer>
      <el-button @click="copyResult">一键复制</el-button>
      <el-button type="primary" @click="resultVisible = false">完成</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { reqReturnOrder } from '@/api/order'
import { showError } from '@/utils/request'
import { fmtQty } from '@/utils/orderQty'

const props = defineProps<{ modelValue: boolean; order: any }>()
const emit = defineEmits<{ 'update:modelValue': [boolean]; success: [] }>()

const dialogVisible = computed({
  get: () => props.modelValue,
  set: (v: boolean) => emit('update:modelValue', v)
})
const resultVisible = ref(false)
const submitting = ref(false)
const formRef = ref<FormInstance>()
const result = ref<any>(null)
const reasons = ['质量问题', '发错货/错发漏发', '客户拒收', '物流损坏', '重复下单', '其他']
const form = reactive({ Reason: '', Remark: '' })
const rules: FormRules = { Reason: [{ required: true, message: '请选择退货原因', trigger: 'change' }] }

const statusMap: Record<number, string> = {
  1: '待审核', 2: '待发货', 3: '部分发货', 4: '已发货', 5: '已签收', 6: '已取消', 7: '已驳回', 8: '已退货'
}
const statusText = (s: number) => statusMap[s] || '未知'
const formatDate = (v: string) => v ? String(v).replace('T', ' ').slice(0, 19) : '—'

const resetForm = () => {
  form.Reason = ''
  form.Remark = ''
  formRef.value?.clearValidate()
}

const submit = async () => {
  if (!formRef.value) return
  try {
    await formRef.value.validate()
  } catch {
    return
  }
  submitting.value = true
  try {
    // 拦截器已把 ApiResponse.Data 拆包成 ReturnOrderResultDto
    const res: any = await reqReturnOrder(props.order.Id, { Reason: form.Reason, Remark: form.Remark || undefined })
    result.value = res || {}
    dialogVisible.value = false
    resultVisible.value = true
    ElMessage.success('退货成功')
    emit('success')
  } catch (e) {
    showError(e, '退货失败')
  } finally {
    submitting.value = false
  }
}

const buildResultText = () => {
  const r: any = result.value || {}
  const lines = [
    '【订单退货结果】',
    `退货单号：${r.ReturnNo || '—'}`,
    `订单编号：${r.OrderNo || '—'}`,
    `经销商：${r.DealerName || '—'}`,
    `状态变化：${statusText(r.BeforeStatus)} → ${statusText(r.AfterStatus)}`,
    `退回箱数：${r.TotalQty ?? 0} 箱`,
    `返还额度：${r.QuotaRestored ?? 0} 箱（${r.BeforeDealerQuota ?? 0} → ${r.AfterDealerQuota ?? 0}）`,
    `运费冲销：¥${r.FreightReversed ?? 0}（余额 ${r.BeforeFreight ?? 0} → ${r.AfterFreight ?? 0}）`,
    `差价冲销：¥${r.PriceDiffReversed ?? 0}（余额 ${r.BeforePriceDiff ?? 0} → ${r.AfterPriceDiff ?? 0}）`,
    `操作人：${r.CreatedByName || '—'}`,
    `退货时间：${formatDate(r.CreatedAt)}`
  ]
  if (r.QuotaChanges?.length) {
    lines.push('额度返还明细：')
    r.QuotaChanges.forEach((q: any) => lines.push(`  - ${q.QuotaName}：${q.BeforeAmount} → ${q.AfterAmount}（+${q.ChangeQuantity}）`))
  }
  if (r.StockChanges?.length) {
    lines.push('库存回退明细：')
    r.StockChanges.forEach((s: any) => lines.push(`  - ${s.ProductName} ${s.Action} ${s.Quantity} 箱 @ ${s.WarehouseName || '—'}`))
  }
  return lines.join('\n')
}

const copyResult = async () => {
  const text = buildResultText()
  try {
    await navigator.clipboard.writeText(text)
    ElMessage.success('已复制到剪贴板')
  } catch {
    const ta = document.createElement('textarea')
    ta.value = text
    document.body.appendChild(ta)
    ta.select()
    document.execCommand('copy')
    document.body.removeChild(ta)
    ElMessage.success('已复制到剪贴板')
  }
}
</script>

<style scoped>
.section { margin-top: 16px; }
.section-title { font-size: 13px; font-weight: 600; margin-bottom: 8px; color: #303133; }
</style>
