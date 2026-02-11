class Emoji {
  static String getEmojiForScore(double percentage) {
    if (percentage >= 95) return '🥳'; // Fiesta
    if (percentage >= 80) return '🎉'; // Celebración
    if (percentage >= 70) return '😊'; // Feliz (Aprobado)
    if (percentage >= 50) return '🤔'; // Pensativo
    if (percentage >= 30) return '😟'; // Preocupado
    return '😢'; // Triste
  } 
}