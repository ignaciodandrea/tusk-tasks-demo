---
name: 🐛 Bug Report
about: Reportar un bug en Tusk Tasks
title: '[BUG] '
labels: ['bug', 'needs-triage']
assignees: ''
---

# 🐛 Bug Report

## 📝 Descripción del Bug
<!-- Una descripción clara y concisa del bug -->

## 🔄 Pasos para Reproducir
1. Ir a '...'
2. Hacer click en '...'
3. Scroll down hasta '...'
4. Ver error

## ✅ Comportamiento Esperado
<!-- Descripción clara de lo que esperabas que pasara -->

## ❌ Comportamiento Actual
<!-- Descripción clara de lo que realmente pasó -->

## 📸 Screenshots
<!-- Si aplica, agrega screenshots para explicar el problema -->

## 🧪 Testing Information

### Tests Relacionados
- [ ] 🧪 **Existing Tests**: ¿Hay tests existentes que cubran esta funcionalidad?
- [ ] ❌ **Failing Tests**: ¿Algún test está fallando relacionado a este bug?
- [ ] 📝 **Test Case**: ¿Podemos escribir un test que reproduzca este bug?

### AI Testing Analysis
- [ ] 🤖 **AI Scan**: ¿Tusk AI identificó este escenario como posible edge case?
- [ ] 📊 **Coverage Gap**: ¿Este bug indica un gap en cobertura de tests?

## 🖥️ Environment

### Device/Simulator
- **Device**: [ej. iPhone 15 Pro, Simulator]
- **OS Version**: [ej. iOS 17.1]
- **App Version**: [ej. 1.0.0]

### Development
- **Xcode Version**: [ej. 16.0]
- **Swift Version**: [ej. 6.0]
- **Testing Framework**: Swift Testing

## 📋 Additional Context

### Frequency
- [ ] 🔥 **Always**: Sucede siempre
- [ ] 🔄 **Often**: Sucede frecuentemente
- [ ] 🎯 **Sometimes**: Sucede a veces
- [ ] 🤔 **Rare**: Muy raro

### Impact
- [ ] 🚨 **Critical**: App crash o pérdida de datos
- [ ] 🔶 **High**: Funcionalidad principal no funciona
- [ ] 🟡 **Medium**: Funcionalidad secundaria afectada
- [ ] 🟢 **Low**: Problema cosmético o menor

### Logs/Error Messages
```
<!-- Pega aquí cualquier log o mensaje de error relevante -->
```

## 🧪 Suggested Test Cases
<!-- Si tienes ideas para tests que prevendrían este bug en el futuro -->

```swift
@Test("Test case that should prevent this bug")
func testCaseName() {
    // Given - setup that leads to the bug
    
    // When - action that triggers the bug
    
    // Then - assertion that would catch the bug
}
```

## 🤖 AI Analysis Request
- [ ] 📊 **Request AI Scan**: Por favor que Tusk AI analice este caso para sugerir tests preventivos
- [ ] 🎯 **Edge Case Analysis**: Revisar si hay otros edge cases similares no cubiertos
- [ ] 📈 **Pattern Detection**: Buscar patrones que podrían indicar bugs similares

---

### 📝 Para el Equipo de Desarrollo
- **Priority**: [Low/Medium/High/Critical]
- **Estimated Effort**: [Small/Medium/Large]
- **Test Strategy**: [Cómo planeas testear el fix]

---

*Recuerda: Un buen bug report con contexto de testing nos ayuda a no solo arreglar el bug, sino también prevenir bugs similares en el futuro.* 