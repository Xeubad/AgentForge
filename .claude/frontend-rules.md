# 前端约束

本文件定义前端开发中的视觉、交互和代码约束。被 `CLAUDE.md` 通过 `@` 引用自动加载。

## 通用原则

- 优先使用项目已有的组件库和设计系统
- 响应式断点使用项目既有 token，不引入新值
- a11y 第一遍就写对（aria-label / role / tab order）
- 动画用 transform 和 opacity，不用 left/top；CSS 动画 > JS 动画

## 技术栈（按项目实际调整）

- React / Vue / 其他框架
- TypeScript strict 模式
- 样式方案（Tailwind / CSS Modules / styled-components 等）

## 组件设计

- 组合 > 配置
- render props / compound components 灵活运用
- 能 memo 就 memo，但绝不无脑用；先 measure 再 optimize

## 性能

- 图片懒加载
- 代码分割
- 避免不必要的重渲染
