//封装一个函数：获取一个结果：当前是早上|上午|下午|晚上
export const getTime = () => {
    let message = '';
    const date = new Date();
    const hours = date.getHours();
    if (hours < 6) {
        message = '凌晨';
    } else if (hours < 12) {
        message = '上午';
    } else if (hours < 18) {
        message = '下午';
    } else {
        message = '晚上';
    }
    return message;
}; 