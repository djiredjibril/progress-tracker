#!/usr/bin/env python3
"""Génère ProgressTracker/Resources/Localizable.xcstrings à partir du tableau ci-dessous.

La clé est le texte ANGLAIS (celui qu'on écrit dans le code) ; la valeur est la traduction française.
Les formats suivent SwiftUI : `%@` pour un texte, `%lld` pour un entier, `%%` pour un « % » littéral.
Usage : python3 tools/localization.py
"""
import json
import pathlib

FR = {
    # --- Onglets et titres
    "Home": "Accueil", "Calendar": "Calendrier", "Analytics": "Statistiques", "Profile": "Profil",
    "Notifications": "Notifications", "Focus Session": "Session de focus", "Edit Profile": "Modifier le profil",
    "New Task": "Nouvelle tâche", "Edit Task": "Modifier la tâche",
    # --- Accueil
    "Good Morning": "Bonjour", "Good Afternoon": "Bon après-midi", "Good Evening": "Bonsoir",
    "Hello, %@ 👋": "Bonjour, %@ 👋", "Hello, %@": "Bonjour, %@",
    "Make today productive\nand achieve your goals.": "Rendez votre journée productive\net atteignez vos objectifs.",
    "Tasks Done": "Tâches faites", "Focus Time": "Focus", "Day Streak": "Série de jours",
    "Today's Goal": "Objectif du jour", "You're %lld%% closer to your goal.": "Vous êtes à %lld%% de votre objectif.",
    "View today's goal": "Voir l'objectif du jour",
    "My Tasks": "Mes tâches", "See All": "Tout voir",
    "No tasks today": "Aucune tâche aujourd'hui", "Plan your day by adding your first task.": "Planifiez votre journée en ajoutant votre première tâche.",
    "Add a task": "Ajouter une tâche", "Add task": "Ajouter une tâche",
    "Loading": "Chargement", "Try again": "Réessayer", "Opens your focus session": "Ouvre votre session de focus",
    "Search": "Rechercher", "Back": "Retour", "Close": "Fermer",
    "Plan your day": "À planifier", "Let's Go!": "C'est parti !", "Keep Going!": "Continuez !", "Goal Reached!": "Bravo !",
    "h": "h", "m": "min",
    # --- Tâches
    "Delete this task?": "Supprimer cette tâche ?", "Delete “%@”": "Supprimer « %@ »", "This cannot be undone.": "Cette action est irréversible.",
    "Cancel": "Annuler", "Delete": "Supprimer", "Edit": "Modifier", "Remove": "Retirer", "Done": "Terminé",
    "Options for %@": "Options pour %@", "Double-tap to toggle": "Appuyez deux fois pour cocher ou décocher",
    "Completed": "Terminée", "Not completed": "Non terminée", "Not done": "Non faite",
    "Create Task": "Créer la tâche", "Save Changes": "Enregistrer", "Title": "Titre", "What do you need to do?": "Que devez-vous faire ?",
    "Date": "Date", "Today": "Aujourd'hui", "Tomorrow": "Demain", "Pick a date": "Choisir une date", "Time": "Heure",
    "Duration": "Durée", "Category": "Catégorie", "Priority": "Priorité", "Remind me 15 min before": "Me rappeler 15 min avant",
    "Work": "Travail", "Health": "Santé", "Learning": "Études", "Personal": "Personnel",
    "Low": "Basse", "Medium": "Moyenne", "High": "Haute",
    "%lld min": "%lld min", "%lld h": "%lld h", "%lld h %lld": "%lld h %lld",
    "%lld task": "%lld tâche", "%lld tasks": "%lld tâches", "%lld task · %lld done": "%lld tâche · %lld faite", "%lld tasks · %lld done": "%lld tâches · %lld faites",
    # --- Calendrier
    "Go to today": "Aller à aujourd'hui", "Previous week": "Semaine précédente", "Next week": "Semaine suivante",
    "Today's Schedule": "Planning du jour", "Tomorrow's Schedule": "Planning de demain", "Yesterday's Schedule": "Planning d'hier",
    "No tasks": "Aucune tâche", "Nothing planned for this day.": "Rien de prévu ce jour-là.",
    ", today": ", aujourd'hui", ", has tasks": ", avec des tâches", "Now, %@": "Maintenant, %@",
    # --- Analytics
    "Week": "Semaine", "Month": "Mois", "Year": "Année",
    "Focus time this week": "Temps de focus cette semaine", "Focus time this month": "Temps de focus ce mois-ci", "Focus time this year": "Temps de focus cette année",
    "Tasks done": "Tâches faites", "Best streak": "Meilleure série", "%lld day": "%lld jour", "%lld days": "%lld jours",
    "Time by category": "Temps par catégorie", "Complete tasks to see where your time goes.": "Terminez des tâches pour voir où va votre temps.",
    "Progress": "Progression", "%lld percent": "%lld pour cent", "W%lld": "S%lld",
    # --- Notifications
    "Mark all as read": "Tout marquer comme lu", "Earlier": "Plus tôt", "Unread": "Non lue",
    "You're all caught up": "Vous êtes à jour", "Finish a task or a focus session and it will show up here.": "Terminez une tâche ou une session de focus et elle apparaîtra ici.",
    "Just now": "À l'instant", "%lldm ago": "il y a %lld min", "%lldh ago": "il y a %lld h", "Yesterday": "Hier",
    "Today, %@": "Aujourd'hui, %@", "Tomorrow, %@": "Demain, %@",
    "Task completed": "Tâche terminée", "%@ was marked as done.": "%@ a été marquée comme terminée.",
    "Daily goal reached": "Objectif du jour atteint", "You completed every task planned for today.": "Vous avez terminé toutes les tâches prévues aujourd'hui.",
    "Focus session complete": "Session de focus terminée", "You focused %lld min on %@.": "Vous avez travaillé %lld min sur %@.", "You focused %lld min.": "Vous avez travaillé %lld min.",
    "%lld-day streak!": "Série de %lld jours !", "You've been active %lld days in a row. Keep it up!": "Vous êtes actif depuis %lld jours d'affilée. Continuez !",
    # --- Focus
    "Complete": "Terminé", "Deep work": "Travail profond", "Break": "Pause", "all sessions done": "toutes les sessions terminées", "of %lld min": "sur %lld min",
    "Next break": "Prochaine pause", "Next focus": "Prochain focus", "All %lld sessions done": "Les %lld sessions sont terminées", "Session %lld of %lld": "Session %lld sur %lld",
    "Focus today": "Focus aujourd'hui", "%@ remaining, %@": "%@ restant, %@", "Reset": "Réinitialiser", "Pause": "Pause", "Start": "Démarrer",
    "Resume": "Reprendre", "Restart": "Recommencer", "Skip to break": "Passer à la pause", "Skip break": "Passer la pause", "Session settings": "Réglages de la session",
    "· %@": "· %@", "%lldh %lldm": "%lld h %lld min", "%lldm": "%lld min",
    # --- Recherche
    "Search tasks": "Rechercher des tâches", "Search by title or category": "Rechercher par titre ou catégorie", "1 result": "1 résultat", "%lld results": "%lld résultats",
    "No tasks match “%@”": "Aucune tâche ne correspond à « %@ »", "Clear search": "Effacer la recherche", "Opens this day in the calendar": "Ouvre ce jour dans le calendrier",
    # --- Profil
    "Daily goal": "Objectif quotidien", "Focus session": "Session de focus", "Appearance": "Apparence", "Language": "Langue",
    "System": "Système", "Light": "Clair", "Dark": "Sombre", "Replay introduction": "Revoir l'introduction", "Help & Support": "Aide et assistance",
    "Log out": "Se déconnecter", "Log out of Progress Tracker?": "Se déconnecter de Progress Tracker ?", "Edit profile": "Modifier le profil",
    "Change photo": "Changer la photo", "First name": "Prénom", "Email": "E-mail", "Enter your first name.": "Saisissez votre prénom.",
    "Enter a valid email address.": "Saisissez une adresse e-mail valide.",
    # --- Entrée
    "Plan. Focus. Achieve.": "Planifiez. Concentrez-vous. Réussissez.", "Progress Tracker": "Progress Tracker",
    "Progress Tracker. Plan. Focus. Achieve.": "Progress Tracker. Planifiez. Concentrez-vous. Réussissez.", "Double-tap to continue": "Appuyez deux fois pour continuer",
    "Plan your day with ease": "Planifiez votre journée sans effort", "Stay in the zone": "Restez concentré", "Watch your progress grow": "Voyez votre progression grandir",
    "Organize your tasks, set a time for each one and see your whole day at a glance.": "Organisez vos tâches, fixez une heure pour chacune et voyez toute votre journée d'un coup d'œil.",
    "Start focus sessions, take breaks at the right time and track the hours you spend on what matters.": "Lancez des sessions de focus, faites des pauses au bon moment et suivez les heures passées sur ce qui compte.",
    "Build streaks, reach your daily goals and see how far you have come each week.": "Enchaînez les jours, atteignez vos objectifs quotidiens et mesurez le chemin parcouru chaque semaine.",
    "Skip": "Passer", "Next": "Suivant", "Get Started": "Commencer", "I already have an account": "J'ai déjà un compte", "Step %lld of %lld": "Étape %lld sur %lld",
    "4 tasks today": "4 tâches aujourd'hui", "%lld-day streak": "Série de %lld jours",
    "Welcome back": "Bon retour", "Log in to pick up where you left off.": "Connectez-vous pour reprendre là où vous vous êtes arrêté.",
    "Password": "Mot de passe", "Your password": "Votre mot de passe", "Forgot password?": "Mot de passe oublié ?", "Log In": "Se connecter", "Log in": "Se connecter",
    "Don't have an account?": "Pas encore de compte ?", "Sign up": "S'inscrire", "Already have an account?": "Vous avez déjà un compte ?",
    "Create your account": "Créez votre compte", "It takes less than a minute.": "Cela prend moins d'une minute.", "Create Account": "Créer le compte", "Create a password": "Créez un mot de passe",
    "At least %lld characters.": "Au moins %lld caractères.", "Use at least %lld characters.": "Utilisez au moins %lld caractères.",
    "I agree to the Terms of Service and Privacy Policy.": "J'accepte les conditions d'utilisation et la politique de confidentialité.",
    "Show password": "Afficher le mot de passe", "Hide password": "Masquer le mot de passe", "Checked": "Coché", "Unchecked": "Décoché",
    "Incorrect email or password.": "E-mail ou mot de passe incorrect.", "An account with this email already exists.": "Un compte existe déjà avec cet e-mail.",
    "Something went wrong. Please try again.": "Une erreur est survenue. Veuillez réessayer.", "Coming soon": "Bientôt disponible",
}


def main() -> None:
    strings = {}
    for key, fr in sorted(FR.items()):
        strings[key] = {"localizations": {
            "en": {"stringUnit": {"state": "translated", "value": key}},
            "fr": {"stringUnit": {"state": "translated", "value": fr}},
        }}
    catalog = {"sourceLanguage": "en", "strings": strings, "version": "1.0"}
    out = pathlib.Path(__file__).resolve().parent.parent / "ProgressTracker" / "Resources" / "Localizable.xcstrings"
    out.write_text(json.dumps(catalog, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"{len(strings)} clés écrites dans {out}")


if __name__ == "__main__":
    main()
