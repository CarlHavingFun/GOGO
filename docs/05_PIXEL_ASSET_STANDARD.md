# GOGO 像素素材规范

## 总原则
素材必须模块化，禁止角色和武器绑定为单张图片。

## 目录规范

assets/

characters/
- nini/
- device/
- big_bro/

weapons/
- ak/
- m4/
- awp/
- deagle/

fx/
- muzzle_flash
- bullet
- smoke
- fire

## 角色素材
每个角色需要：
- idle
- walk
- shoot
- hurt
- skill

## 武器素材
每把枪需要：
- weapon sprite
- bullet
- muzzle flash
- reload animation

## AI生成要求
统一像素艺术风格，保持：
- 统一尺寸
- 统一视角
- 统一色板
- 可拆分动画帧

## 目标
支持 Godot 动态组合：
角色 + 武器 + 特效 + 皮肤。
