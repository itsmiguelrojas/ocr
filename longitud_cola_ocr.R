# Reconocimiento óptico de caracteres en tablas de datos
# Imagen tomada del libro "Biología e investigación científica"
# de Jeffrey J. W. Baker y Garland E. Allen.
# (Traducción de Jaime F. George C. e Ina Sheila Figueroa de Uphoff.)
# El contraste de la imagen fue editado hasta un aumento del 55 %
# para garantizar la legibilidad

# Instalar librerías (desmarque el '#" para instalar)
# install.packages('tidyverse')
# install.packages('hrbrthemes')
# install.packages('tesseract')
# install.packages('ggtext')
# install.packages('gridExtra')

# Cargar librerías
library(tidyverse)
library(hrbrthemes)
library(tesseract)
library(ggtext)
library(gridExtra)

# Reconocimiento de imagen
tabla_imagen <- "https://raw.githubusercontent.com/itsmiguelrojas/ocr/main/tabla_editada.jpg"
tabla_data_raw <- ocr_data(tabla_imagen)

# Transformar caracteres en númericos
tabla_data <- as.numeric(gsub(",",".",tabla_data_raw$word))

# Eliminar imagen y raw
rm(tabla_data_raw, tabla_imagen)

# Crear factor
observadores <- factor(
  rep(c('Observador 1', 'Observador 2', 'Observador 3'),15)
)

# Crear dataframe
longitud_cola <- data.frame(
  longitud = tabla_data,
  observadores
)

# Borrar variables
rm(observadores, tabla_data)

# Prueba de normalidad (Shapiro-Wilk)

# Solo observador 1
obs_1 <- longitud_cola %>%
  filter(grepl('Observador 1', observadores))

shapiro.test(obs_1$longitud) # W = 0.94533, p-value = 0.4541

# Solo observador 2
obs_2 <- longitud_cola %>%
  filter(grepl('Observador 2', observadores))

shapiro.test(obs_2$longitud) # W = 0.97763, p-value = 0.9507

# Solo observador 3
obs_3 <- longitud_cola %>%
  filter(grepl('Observador 3', observadores))

shapiro.test(obs_3$longitud) # W = 0.95989, p-value = 0.6904

# Prueba ANOVA
modelo <- lm(longitud ~ observadores, longitud_cola)
anova(modelo)

# Response: longitud
# Df Sum Sq Mean Sq F value Pr(>F)
# observadores  2   6.43  3.2167  0.2188 0.8044
# Residuals    42 617.44 14.7009

# Conclusión: no hay una diferencia significativa entre las
# mediciones de los tres observadores

aov.modelo <- aov(modelo)

# Hacer gráfico de densidad
main.title <- expression('Longitud de la cola de\nejemplares de ratones del género ' *italic(Peromyscus)*'')

density.plot <- longitud_cola %>%
  ggplot(aes(x = longitud, fill = observadores)) +
  geom_histogram(bins = 7, color = 'black') +
  labs(
    x = 'Longitud',
    y = 'Frecuencia',
    title = main.title,
    subtitle = 'Datos tomados de la tabla 5-3 (pág. 70)',
    caption = 'Baker, J; Allen, G. (1970). Biología e investigación científica (George, F., Uphoff, I., Trad.).\nFondo Educativo Interamericano S. A., Massachussets, EUA.'
  ) +
  scale_fill_manual(values = c('#5E3E56','#C87013','#FDFF35')) +
  theme_ipsum() +
  guides(fill = guide_legend(title = ''))

############################
# Organizar datos en tabla #
############################

# Reorganizar datos
tabla <- data.frame(
  obs_1$longitud,
  obs_2$longitud,
  obs_3$longitud
)

# Cambiar nombre de las columnas
colnames(tabla) <- c('Observador 1','Observador 2','Observador 3')

# Juntar gráficos
grid.arrange(
  density.plot,
  tableGrob(tabla, rows = NULL),
  ncol = 2
)

# Remover variables
rm(obs_1, obs_2, obs_3)