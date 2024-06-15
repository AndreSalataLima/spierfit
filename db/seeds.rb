# # Clear database
# ExerciseSet.destroy_all
# Workout.destroy_all
# Exercise.destroy_all
# Personal.destroy_all
# User.destroy_all
# Gym.destroy_all

# # Create gyms
# gyms = Gym.create!([
#   { name: 'Gym One', location: 'Downtown', contact_info: '123-456-7890', hours_of_operation: '6am - 10pm', equipment_list: 'Treadmills, Weights, Machines', policies: 'No outside shoes', subscriptions: 'Monthly, Annual', photos: 'photo1.jpg,photo2.jpg', events: 'Yoga class, HIIT class', capacity: 100, safety_protocols: 'Sanitize equipment after use' },
#   { name: 'Gym Two', location: 'Uptown', contact_info: '987-654-3210', hours_of_operation: '5am - 11pm', equipment_list: 'Bikes, Rowers, Weights', policies: 'Mask required', subscriptions: 'Monthly, Quarterly', photos: 'photo3.jpg,photo4.jpg', events: 'Spinning class, Zumba class', capacity: 150, safety_protocols: 'Temperature check' },
#   { name: 'Gym Three', location: 'Midtown', contact_info: '555-123-4567', hours_of_operation: '24 hours', equipment_list: 'Machines, Free Weights', policies: 'Wipe down after use', subscriptions: 'Monthly, Annual, Daily', photos: 'photo5.jpg,photo6.jpg', events: 'Pilates class, Bootcamp', capacity: 200, safety_protocols: 'Hand sanitizer stations' },
#   { name: 'Gym Four', location: 'Westside', contact_info: '321-654-9870', hours_of_operation: '6am - 8pm', equipment_list: 'Ellipticals, Treadmills, Kettlebells', policies: 'No food', subscriptions: 'Monthly, Annual', photos: 'photo7.jpg,photo8.jpg', events: 'Crossfit, Yoga class', capacity: 80, safety_protocols: 'Regular cleaning' },
#   { name: 'Gym Five', location: 'Eastside', contact_info: '789-456-1230', hours_of_operation: '7am - 9pm', equipment_list: 'Machines, Free Weights, Dumbbells', policies: 'No pets', subscriptions: 'Monthly, Semi-Annual', photos: 'photo9.jpg,photo10.jpg', events: 'HIIT class, Meditation session', capacity: 120, safety_protocols: 'Social distancing' }
# ])

# # Create users
# users = User.create!([
#   { name: 'John Doe', email: 'john.doe@example.com', password: 'password', phone: '123-456-7890', address: '123 Main St', status: 'Active', date_of_birth: '1985-01-01', height: 180, weight: 75, gym: gyms[0] },
#   { name: 'Jane Smith', email: 'jane.smith@example.com', password: 'password', phone: '987-654-3210', address: '456 Elm St', status: 'Active', date_of_birth: '1990-02-02', height: 165, weight: 60, gym: gyms[1] },
#   { name: 'Alice Jones', email: 'alice.jones@example.com', password: 'password', phone: '555-123-4567', address: '789 Oak St', status: 'Active', date_of_birth: '1987-03-03', height: 170, weight: 65, gym: gyms[2] },
#   { name: 'Bob Brown', email: 'bob.brown@example.com', password: 'password', phone: '321-654-9870', address: '101 Maple St', status: 'Active', date_of_birth: '1992-04-04', height: 175, weight: 70, gym: gyms[3] },
#   { name: 'Carol White', email: 'carol.white@example.com', password: 'password', phone: '789-456-1230', address: '202 Birch St', status: 'Active', date_of_birth: '1989-05-05', height: 160, weight: 55, gym: gyms[4] }
# ])

# # Create personal trainers
# personals = Personal.create!([
#   { user: users[0], name: 'Alice Johnson', email: 'alice.johnson@example.com', password: 'password123', password_confirmation: 'password123', specialization: 'Strength Training', availability: 'Weekdays', bio: 'Certified personal trainer with 10 years of experience.', rating: '5 stars', languages: 'English, Spanish', emergency_contact: '123-456-7890', current_clients: 10, certifications: 'CPT, CSCS', photos: 'trainer1.jpg', plans: 'Monthly, Annual', achievements: 'Bodybuilding champion' },
#   { user: users[1], name: 'Bob Smith', email: 'bob.smith@example.com', password: 'password123', password_confirmation: 'password123', specialization: 'Cardio Fitness', availability: 'Weekends', bio: 'Expert in cardio and endurance training.', rating: '4.5 stars', languages: 'English, French', emergency_contact: '987-654-3210', current_clients: 8, certifications: 'ACE, CPT', photos: 'trainer2.jpg', plans: 'Monthly, Quarterly', achievements: 'Marathon finisher' },
#   { user: users[2], name: 'Carol White', email: 'carol.white@example.com', password: 'password123', password_confirmation: 'password123', specialization: 'Yoga', availability: 'Mornings', bio: 'Experienced yoga instructor with a holistic approach.', rating: '5 stars', languages: 'English, Hindi', emergency_contact: '555-123-4567', current_clients: 12, certifications: 'RYT-500', photos: 'trainer3.jpg', plans: 'Monthly, Semi-Annual', achievements: 'Yoga retreat leader' },
#   { user: users[3], name: 'David Brown', email: 'david.brown@example.com', password: 'password123', password_confirmation: 'password123', specialization: 'Pilates', availability: 'Afternoons', bio: 'Pilates instructor focusing on core strength and flexibility.', rating: '4 stars', languages: 'English, German', emergency_contact: '321-654-9870', current_clients: 6, certifications: 'Pilates Mat, Reformer', photos: 'trainer4.jpg', plans: 'Monthly, Annual', achievements: 'Fitness conference speaker' },
#   { user: users[4], name: 'Eva Green', email: 'eva.green@example.com', password: 'password123', password_confirmation: 'password123', specialization: 'CrossFit', availability: 'Evenings', bio: 'CrossFit coach with a background in functional training.', rating: '4.5 stars', languages: 'English, Portuguese', emergency_contact: '789-456-1230', current_clients: 15, certifications: 'CrossFit Level 1, CSCS', photos: 'trainer5.jpg', plans: 'Monthly, Quarterly', achievements: 'CrossFit regional competitor' }
# ])

# # Create exercises
# exercises = Exercise.create!([
#   { name: 'Push Up', description: 'Push up exercise for upper body strength.', muscle_group: 'Chest', difficulty: 'Medium', instructions: 'Keep your back straight.', variants: 'Wide grip, Narrow grip', equipment_needed: 'None', contraindications: 'Shoulder injury', benefits: 'Strengthens chest and triceps', duration_suggested: 10, frequency_recommended: 3, progression_levels: 'Beginner, Intermediate, Advanced' },
#   { name: 'Squat', description: 'Squat exercise for lower body strength.', muscle_group: 'Legs', difficulty: 'Medium', instructions: 'Keep your knees behind your toes.', variants: 'Sumo squat, Jump squat', equipment_needed: 'None', contraindications: 'Knee injury', benefits: 'Strengthens legs and glutes', duration_suggested: 15, frequency_recommended: 3, progression_levels: 'Beginner, Intermediate, Advanced' },
#   { name: 'Pull Up', description: 'Pull up exercise for upper body strength.', muscle_group: 'Back', difficulty: 'Hard', instructions: 'Pull your chin above the bar.', variants: 'Wide grip, Chin up', equipment_needed: 'Pull up bar', contraindications: 'Elbow injury', benefits: 'Strengthens back and biceps', duration_suggested: 5, frequency_recommended: 3, progression_levels: 'Beginner, Intermediate, Advanced' },
#   { name: 'Plank', description: 'Plank exercise for core strength.', muscle_group: 'Core', difficulty: 'Medium', instructions: 'Keep your body straight.', variants: 'Side plank, Extended plank', equipment_needed: 'None', contraindications: 'Lower back pain', benefits: 'Strengthens core muscles', duration_suggested: 5, frequency_recommended: 3, progression_levels: 'Beginner, Intermediate, Advanced' },
#   { name: 'Deadlift', description: 'Deadlift exercise for total body strength.', muscle_group: 'Full Body', difficulty: 'Hard', instructions: 'Lift with your legs, not your back.', variants: 'Sumo deadlift, Romanian deadlift', equipment_needed: 'Barbell', contraindications: 'Lower back injury', benefits: 'Strengthens entire body', duration_suggested: 10, frequency_recommended: 3, progression_levels: 'Beginner, Intermediate, Advanced' }
# ])

# # Create workouts
# users.each_with_index do |user, i|
#   user.workouts.create!([
#     { personal: personals[i], gym: gyms[i], workout_type: 'Strength', goal: 'Muscle Gain', duration: 60, calories_burned: 500, intensity: 'High', feedback: 'Great session', modifications: 'None', intensity_general: 'High', difficulty_perceived: 'Medium', performance_score: 8, auto_adjustments: 'None' },
#     { personal: personals[i], gym: gyms[i], workout_type: 'Cardio', goal: 'Endurance', duration: 45, calories_burned: 400, intensity: 'Medium', feedback: 'Good session', modifications: 'None', intensity_general: 'Medium', difficulty_perceived: 'Easy', performance_score: 7, auto_adjustments: 'Increase intensity' }
#   ])
# end

# # Create exercise sets
# Workout.all.each_with_index do |workout, i|
#   workout.exercise_sets.create!([
#     { exercise: exercises[i % exercises.size], reps: 10, sets: 3, weight: 20, duration: 30, rest_time: 60, intensity: 'Medium', feedback: 'Felt good', max_reps: 12, performance_score: 8, effort_level: 'High', energy_consumed: 100 },
#     { exercise: exercises[(i + 1) % exercises.size], reps: 15, sets: 4, weight: 25, duration: 40, rest_time: 70, intensity: 'High', feedback: 'Challenging', max_reps: 18, performance_score: 9, effort_level: 'Very High', energy_consumed: 150 }
#   ])
# end

# # Update users with personal trainers
# users.each_with_index do |user, i|
#   user.update(personal: personals[i])
# end


Exercise.create!(
  name: "Supino Reto Barra",
  description: "Exercício básico para o desenvolvimento da massa muscular do peitoral, utilizando uma barra para aumentar a resistência.",
  muscle_group: "Peitoral",
  difficulty: "Intermediário",
  instructions: "Deite-se em um banco plano, segure a barra com as mãos espaçadas na largura dos ombros, retire-a do suporte e abaixe até o peito, depois empurre-a para cima até estender completamente os braços.",
  variants: "Supino com pegada fechada, Supino com pegada ampla",
  equipment_needed: "Banco de supino, Barra livre",
  contraindications: "Evitar em caso de lesões no ombro ou na região cervical",
  benefits: "Aumento da massa muscular, fortalecimento dos músculos do peitoral e dos tríceps",
  duration_suggested: "45 segundos por série",
  frequency_recommended: "2-3 vezes por semana",
  progression_levels: "Aumentar peso ou repetições conforme a adaptação"
)

Exercise.create!(
  name: "Levantamento Terra",
  description: "Um dos exercícios mais completos para o desenvolvimento da força e massa muscular, trabalhando principalmente os músculos dorsais, além de pernas e lombar.",
  muscle_group: "Dorsais",
  difficulty: "Avançado",
  instructions: "Com os pés na largura dos ombros, abaixe-se e segure a barra com as mãos um pouco mais largas que os joelhos. Levante a barra mantendo-a próxima ao corpo, estenda completamente os quadris e joelhos.",
  variants: "Levantamento terra sumô, levantamento terra com pegada mista.",
  equipment_needed: "Barra livre",
  contraindications: "Lesões lombares prévias, problemas de coluna.",
  benefits: "Aumento da força global, melhoria da postura, ganho de massa muscular.",
  duration_suggested: "30 segundos por série",
  frequency_recommended: "2 vezes por semana",
  progression_levels: "Aumento progressivo do peso"
)

Exercise.create!(
  name: "Curls de Bíceps com Halteres",
  description: "Exercício clássico para desenvolver os músculos dos bíceps, utilizando halteres para permitir um movimento mais natural e isolado.",
  muscle_group: "Bíceps",
  difficulty: "Iniciante",
  instructions: "Em pé, segure um haltere em cada mão ao lado do corpo, palmas voltadas para frente. Flexione os cotovelos para levantar os halteres em direção aos ombros, mantendo os cotovelos fixos ao lado do corpo.",
  variants: "Curl martelo, Curl concentrado.",
  equipment_needed: "Halteres",
  contraindications: "Lesões no cotovelo ou antebraço.",
  benefits: "Aumento da massa muscular dos bíceps, melhoria da força de preensão.",
  duration_suggested: "30 segundos por série",
  frequency_recommended: "2-3 vezes por semana",
  progression_levels: "Aumentar o peso dos halteres conforme a força aumenta"
)

Exercise.create!(
  name: "Agachamento Livre",
  description: "Exercício fundamental para o desenvolvimento das coxas, envolvendo múltiplos grupos musculares incluindo quadríceps, isquiotibiais e glúteos.",
  muscle_group: "Coxas",
  difficulty: "Intermediário",
  instructions: "Com os pés na largura dos ombros, segure uma barra sobre os ombros atrás do pescoço. Agache-se até que as coxas estejam paralelas ao chão, mantendo as costas retas e os joelhos alinhados com os pés. Retorne à posição inicial.",
  variants: "Agachamento frontal, agachamento com halteres.",
  equipment_needed: "Barra livre, rack de agachamento.",
  contraindications: "Lesões no joelho ou lombar, problemas de coluna.",
  benefits: "Fortalecimento de toda a musculatura inferior, melhoria da força e estabilidade do núcleo corporal, aumento da massa muscular.",
  duration_suggested: "45 segundos por série",
  frequency_recommended: "2-3 vezes por semana",
  progression_levels: "Aumentar o peso da barra conforme a força aumenta"
)

puts "Seed data created successfully!"
