import { url } from "inspector"

//创建一个用户信息数据接口
function createFakeUser() {
  return [
    {
        id: 1,
        name: 'John Doe',
        email: '',
        phone: '',
        avatar: 'https://example.com/avatar1.png',
        role: 'admin',
        permissions: ['read', 'write', 'execute'],
        createdAt: '2023-01-01',
        updatedAt: '2023-01-02',
        status: 'active',
        token: 'fake-token',
        username: 'admin',
        password:'123456'

    },{
        id: 2,
        name: 'Jane Smith',
        email: '',
        phone: '',
        avatar: 'https://example.com/avatar2.png',
        role: 'user',
        permissions: ['read'],
        createdAt: '2023-01-03',
        updatedAt: '2023-01-04',
        status: 'inactive',
        token: 'fake-token2',
        username: 'admin1',
        password:'123456'
    },
    {
        id: 3,
        name: 'Alice Johnson',
        email: '',
        phone: '',
        avatar: 'https://example.com/avatar3.png',
        role: 'editor',
        permissions: ['read', 'write'],
        createdAt: '2023-01-05',
        updatedAt: '2023-01-06',
        status: 'active',
        token: 'fake-token3',
        username: 'admin2',
        password:'123456'
    }
  ]
}
//登录接口
export default [
    //用户登录接口
    {
        url: '/api/login',
        method: 'post',
        response: (req: any) => {
            const { username, password } = req.body;
            //模拟登录成功
            if (username === 'admin' && password === '123456') {
                return {
                    code: 200,
                    message: '登录成功',
                    data: {
                        token: 'fake-token',
                        userInfo: createFakeUser()[0]
                    }
                }
            } else {
                return {
                    code: 401,
                    message: '用户名或密码错误',
                    data: null
                }
            }
        }
    },
    //获取用户信息接口
    {
        url: '/api/user/info',
        method: 'get',
        response: (req: any) => {
            //获取请求头token
            const token = req.headers['authorization'];
            //查看用户信息createFakeUser是否包含请求的token用户
            const user = createFakeUser().find((user) => user.token === token);
            //如果没有找到用户，返回401
            if (!user) {    
                return {
                    code: 401,
                    message: '用户未登录或token无效',
                    data: null
                }
            }
            //模拟获取用户信息
            return {
                code: 200,
                message: '获取用户信息成功',
                data: createFakeUser()[0]
            }
        }
    }
]