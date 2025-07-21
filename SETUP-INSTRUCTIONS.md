# 🚀 Configuración de Demo: AI Testing Platform

> **Guía paso a paso** para configurar la demo de testing automatizado con IA

---

## 📋 Prerequisitos

### 1. **Cuentas Necesarias**
- ✅ **GitHub Account**: Para repositorio y Actions
- ✅ **OpenAI Account**: Para GPT-4 API access
- ✅ **Xcode 16+**: Para desarrollo iOS

### 2. **API Keys Requeridas**
- 🔑 **OpenAI API Key**: `sk-...` (necesaria para análisis de IA)
- 💰 **Costo Estimado**: $0.03-0.06 por análisis (very low cost)

---

## ⚙️ Configuración Paso a Paso

### **Paso 1: Configurar OpenAI API Key**

1. **Obtener API Key**:
   - Ir a: https://platform.openai.com/api-keys
   - Click "Create new secret key"
   - Copiar la key (formato: `sk-...`)

2. **Configurar en GitHub**:
   ```bash
   # En tu repositorio GitHub:
   Settings → Secrets and variables → Actions → New repository secret
   
   Name: OPENAI_API_KEY
   Secret: sk-tu-api-key-aqui
   ```

### **Paso 2: Verificar Workflow**

El archivo `.github/workflows/tusk-ai-testing.yml` debe estar en tu repositorio.

**Componentes clave:**
```yaml
- name: 🤖 Tusk AI Code & Test Analysis
  uses: freeedcom/ai-codereviewer@main
  with:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
    OPENAI_API_MODEL: "gpt-4"
```

### **Paso 3: Configurar Repositorio**

1. **Repository Settings**:
   ```
   Settings → General → Features
   ✅ Issues
   ✅ Pull requests
   ✅ Actions
   ```

2. **Actions Permissions**:
   ```
   Settings → Actions → General
   ✅ Allow all actions and reusable workflows
   ✅ Allow GitHub Actions to create and approve pull requests
   ```

3. **Branch Protection** (Opcional):
   ```
   Settings → Branches → Add rule
   Branch name pattern: main
   ✅ Require status checks to pass before merging
   ```

---

## 🎬 Preparar la Demo

### **1. Crear Branch de Prueba**
```bash
git checkout -b demo/ai-testing-showcase
```

### **2. Hacer Cambios Mínimos**
```bash
# Ejemplo: Agregar comentario al código
echo "// Demo change for AI analysis" >> TuskApp/TaskViewModel.swift
git add .
git commit -m "feat: add demo functionality for AI testing showcase"
git push -u origin demo/ai-testing-showcase
```

### **3. Crear Pull Request**
1. Ve a GitHub repository
2. Click "Compare & pull request"
3. **Title**: `🤖 Demo: AI Testing Analysis Showcase`
4. **Description**:
   ```markdown
   ## 🎯 Demo Pull Request
   
   Esta PR demuestra las capacidades de análisis de IA para testing.
   
   ### Cambios
   - Modificación menor para activar análisis de IA
   - Testing de integración con GPT-4
   
   ### Esperado
   - ✅ AI Code Review Action debería analizar automáticamente
   - ✅ Comentarios inteligentes sobre testing gaps
   - ✅ Sugerencias específicas de tests a implementar
   ```

---

## 🧪 Validar Funcionamiento

### **Durante la Demo, deberías ver:**

1. **GitHub Actions ejecutándose**:
   - ✅ Workflow "🐘 Tusk AI - Intelligent Test Analysis" inicia
   - ✅ Tests existentes se ejecutan
   - ✅ AI analysis se completa

2. **Comentarios de IA en el PR**:
   - 🤖 Comentarios específicos en líneas de código
   - 📊 Dashboard de análisis como artifact
   - 💬 Summary comment con métricas

3. **Artifacts generados**:
   - 📋 "tusk-ai-analysis-dashboard" disponible para download

---

## 🎯 Script de Presentación

### **Narración Sugerida:**

> "Lo que van a ver es **IA real** analizando nuestro código Swift. No es simulación - es **GPT-4 ejecutándose en tiempo real** a través de GitHub Actions."

> "Cuando creo esta PR, automáticamente se **activa nuestro pipeline de AI testing** que usa la AI Code Review Action integrada con OpenAI."

> "En menos de 2 minutos, el sistema **analiza toda la codebase**, identifica gaps de testing, y **sugiere tests específicos** usando la sintaxis moderna de Swift Testing."

---

## 🔧 Troubleshooting

### **Problemas Comunes:**

1. **Workflow no se ejecuta**:
   - ✅ Verificar que Actions esté habilitado
   - ✅ Confirmar que el archivo `.yml` esté en `.github/workflows/`

2. **API Key error**:
   - ✅ Verificar que `OPENAI_API_KEY` esté configurada como secret
   - ✅ Confirmar que la API key es válida
   - ✅ Check OpenAI billing/credits

3. **AI no comenta en PR**:
   - ✅ Verificar permisos del token: `pull-requests: write`
   - ✅ Confirmar que el workflow se completa exitosamente

### **Debug Commands:**
```bash
# Verificar workflow status
gh workflow list

# Ver logs de ejecución
gh run list
gh run view [run-id] --log

# Test API key locally
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
  https://api.openai.com/v1/models
```

---

## 💰 Costos Estimados

### **OpenAI API Usage:**
- **Por análisis**: ~$0.03-0.06 USD
- **Por demo (5 PRs)**: ~$0.15-0.30 USD
- **Mensual (50 PRs)**: ~$1.50-3.00 USD

**Extremely cost-effective** para el valor que proporciona.

---

## 🎉 Ready para Demo!

Una vez completada la configuración:

✅ **Demo funcional** con IA real  
✅ **Workflow automatizado** en GitHub  
✅ **Costos mínimos** para operación  
✅ **Presentación convincente** de tecnología cutting-edge  

🚀 **¡Tu demo de AI Testing Platform está lista para impresionar!** 