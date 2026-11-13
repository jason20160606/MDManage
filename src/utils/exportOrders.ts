import { ElMessage } from 'element-plus'
import { reqExportOrders } from '@/api/order'
import { showError } from '@/utils/request'

/**
 * 导出选中订单为 Excel。
 *
 * 各订单页原来各写一份下载逻辑，其中 5 份只是「TODO + 弹一个导出成功」，
 * 实际没有调接口。这里统一收口：没有选中项给提示，失败给真实原因。
 * 拦截器在 responseType=blob 时返回完整 AxiosResponse，所以取 res.data。
 */
export async function exportSelectedOrders(rows: any[]): Promise<boolean> {
  const ids = (rows || [])
    .map(r => Number(r?.Id ?? r?.id))
    .filter(n => Number.isFinite(n) && n > 0)

  if (!ids.length) {
    ElMessage.warning('请选择要导出的订单')
    return false
  }

  try {
    const res: any = await reqExportOrders(ids)
    const blob = new Blob([res.data], {
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `订单导出_${new Date().toLocaleDateString()}.xlsx`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
    return true
  } catch (e) {
    showError(e, '导出失败')
    return false
  }
}
