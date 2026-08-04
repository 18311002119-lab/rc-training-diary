# RC练车电子教练

在线训练日记，前端托管于 GitHub Pages，数据存储于 Supabase。

## 已配置

- Supabase Project URL: `https://wrfjcunspxqmnupimrxm.supabase.co`
- 浏览器端 publishable key 已写入 `config.js`
- 当前教练导入数据写在 `coach_updates.json`
- 网页登录后会自动把尚未导入的教练记录写入当前用户的 Supabase 数据库

## 一次性设置

### 1. 初始化数据库

进入 Supabase Dashboard → SQL Editor → New query，复制并运行 `schema.sql` 全部内容。

### 2. 配置登录回调

假设 GitHub 用户名为 `18311002119-lab`，仓库名为 `rc-training-diary`，网站地址为：

`https://18311002119-lab.github.io/rc-training-diary/`

进入 Supabase Dashboard → Authentication → URL Configuration：

- Site URL：填上述网址
- Redirect URLs：添加上述网址，可再添加带通配符的
  `https://18311002119-lab.github.io/rc-training-diary/**`

### 3. 创建并连接 GitHub 仓库

新建公开仓库 `rc-training-diary`，勾选 README。创建后确保 ChatGPT 的 GitHub 连接有权访问该仓库。

### 4. 部署

把本目录全部文件上传到仓库 `main` 分支。然后打开：

Settings → Pages → Build and deployment → Source → GitHub Actions

推送后等待 Pages 工作流完成。

## 使用方式

- 你：打开网站，用邮箱 Magic Link 登录，然后直接填写训练表单。
- AI教练：在聊天中收到你的截图或成绩后，更新仓库中的 `coach_updates.json`。
- 你下次登录/刷新网页时，尚未导入的教练记录会自动写入你的 Supabase 账户。
- `external_id` 用于防止重复导入。

## 安全

- `config.js` 中只有 Supabase publishable key，可用于浏览器。
- 数据表启用了 RLS，每个登录用户只能读写自己的记录。
- 不要把 `sb_secret_...`、legacy `service_role` 或数据库密码写入仓库、网页或聊天。
