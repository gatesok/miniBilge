DO $$
DECLARE
    ep_id uuid;
BEGIN
    ep_id := gen_random_uuid();

-- Episode kaydı
INSERT INTO podcast_episodes ("Id", "Title", "Description", "EnglishLevel", "DisplayOrder", "IsActive", "CreatedAt")
VALUES (
    ep_id,
    'Anna''s New Life',
    'An A1-A2 level story about a young woman named Anna. She moves from a small village to a big city, finds an apartment, meets new people, and starts a new job.',
    2,   -- 1: A1, 2: A2, 3: B1, 4: B2, 5: C1, 6: C2
    4,   -- DisplayOrder (Sıralama)
    TRUE,
    NOW()
);

-- Satırlar (DisplayOrder sırası önemli, Türkçe çevirilerle birlikte)
-- SpeakerGender: 0 = Male, 1 = Female

INSERT INTO podcast_lines ("Id", "EpisodeId", "SpeakerName", "SpeakerGender", "Text", "TranslationTr", "DisplayOrder", "CreatedAt")
VALUES

-- SCENE 1: LEAVING HOME
(gen_random_uuid(), ep_id, 'Narrator', 0,
 'Anna is twenty-two years old. She lives in a very small village. The village is quiet and beautiful. There are many trees, small houses, and a river. But Anna wants something different. She wants to live in a big city.',
 'Anna yirmi iki yaşındadır. Çok küçük bir köyde yaşamaktadır. Köy sessiz ve güzeldir. Birçok ağaç, küçük evler ve bir nehir vardır. Ancak Anna farklı bir şey istemektedir. Büyük bir şehirde yaşamak istemektedir.',
 1, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'Today is Monday. It is six o''clock in the morning. Anna wakes up early. She gets out of bed and looks out the window. The sky is dark, and it is a little cold.',
 'Bugün günlerden Pazartesi. Sabah saat altı. Anna erkenden uyanır. Yataktan kalkar ve pencereden dışarı bakar. Gökyüzü karanlıktır ve hava biraz soğuktur.',
 2, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Today is the day. I am moving to London. I am very excited, but my stomach hurts a little. I am nervous. I have two big suitcases. They are very heavy.',
 'O gün bugün. Londra''ya taşınıyorum. Çok heyecanlıyım ama midem biraz ağrıyor. Gerginim. İki büyük bavulum var. Çok ağırlar.',
 3, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'Anna goes to the kitchen. Her mother and father are there. Her mother is cooking eggs, and her father is drinking hot coffee. They look sad because their daughter is leaving.',
 'Anna mutfağa gider. Annesi ve babası oradadır. Annesi yumurta pişirmektedir ve babası sıcak kahve içmektedir. Kızları ayrıldığı için üzgün görünmektedirler.',
 4, NOW()),

(gen_random_uuid(), ep_id, 'Mother', 1,
 'Good morning, Anna. Come and eat your breakfast. You have a long journey today. You need energy.',
 'Günaydın Anna. Gel ve kahvaltını yap. Bugün uzun bir yolculuğun var. Enerjiye ihtiyacın var.',
 5, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Thank you, Mom. The eggs are delicious. But I can''t eat a lot. I am too excited.',
 'Teşekkürler anne. Yumurtalar çok lezzetli. Ama çok fazla yiyemem. Çok heyecanlıyım.',
 6, NOW()),

(gen_random_uuid(), ep_id, 'Father', 0,
 'Do you have your train ticket? Do you have your money and your passport? Please check your bag again, Anna. London is a very big city. You must be careful.',
 'Tren biletin yanında mı? Paran ve pasaportun yanında mı? Lütfen çantanı tekrar kontrol et Anna. Londra çok büyük bir şehir. Dikkatli olmalısın.',
 7, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Yes, Dad. Everything is in my bag. Don''t worry. I will be fine. I will call you every evening.',
 'Evet baba. Her şey çantamda. Endişelenme. İyi olacağım. Sizi her akşam arayacağım.',
 8, NOW()),

-- SCENE 2: THE TRAIN JOURNEY
(gen_random_uuid(), ep_id, 'Narrator', 0,
 'At eight o''clock, Anna arrives at the train station. She hugs her parents. She cries a little. Then, she gets on the train. The train is very big and fast. Anna finds her seat next to the window.',
 'Saat sekizde Anna tren istasyonuna varır. Anne babasına sarılır. Biraz ağlar. Sonra trene biner. Tren çok büyük ve hızlıdır. Anna pencere kenarındaki koltuğunu bulur.',
 9, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'The journey takes four hours. Anna looks out the window. She sees green fields, farms, and animals. Then, she reads a book. After two hours, she is hungry. She eats an apple and drinks some water.',
 'Yolculuk dört saat sürer. Anna pencereden dışarı bakar. Yeşil tarlaları, çiftlikleri ve hayvanları görür. Sonra bir kitap okur. İki saat sonra acıkır. Bir elma yer ve biraz su içer.',
 10, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Wow, look at those tall buildings! There are so many cars and buses. The streets are very busy. I am finally in London. It is so different from my village.',
 'Vay canına, şu yüksek binalara bak! O kadar çok araba ve otobüs var ki. Sokaklar çok kalabalık. Sonunda Londra''dayım. Benim köyümden çok farklı.',
 11, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'The train stops at the central station. Anna takes her two heavy suitcases. She walks out of the station. She needs to find a taxi. She sees a red bus and a black taxi. She waves her hand.',
 'Tren merkez istasyonunda durur. Anna iki ağır bavulunu alır. İstasyondan dışarı yürür. Bir taksi bulması gerekmektedir. Kırmızı bir otobüs ve siyah bir taksi görür. Elini sallar.',
 12, NOW()),

(gen_random_uuid(), ep_id, 'Taxi Driver', 0,
 'Hello, miss. Where do you want to go today?',
 'Merhaba hanımefendi. Bugün nereye gitmek istiyorsunuz?',
 13, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Hello. I want to go to 42 Baker Street, please. How much is it?',
 'Merhaba. Lütfen 42 Baker Sokağı''na gitmek istiyorum. Ne kadar tutar?',
 14, NOW()),

(gen_random_uuid(), ep_id, 'Taxi Driver', 0,
 'It is about fifteen pounds. Please put your bags in the back. Sit down and put on your seatbelt.',
 'Yaklaşık on beş sterlin. Lütfen çantalarınızı arkaya koyun. Oturun ve emniyet kemerinizi takın.',
 15, NOW()),

-- SCENE 3: THE NEW APARTMENT
(gen_random_uuid(), ep_id, 'Narrator', 0,
 'Twenty minutes later, the taxi stops. Anna pays the driver and takes her bags. She stands in front of a tall, grey building. This is her new home. She has a key. She opens the big door and walks up the stairs.',
 'Yirmi dakika sonra taksi durur. Anna şoföre ödeme yapar ve çantalarını alır. Uzun, gri bir binanın önünde durur. Burası onun yeni evidir. Bir anahtarı vardır. Büyük kapıyı açar ve merdivenleri çıkar.',
 16, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'Her apartment is on the third floor. It is apartment number seven. She puts the key in the door. She opens it and walks inside. The apartment is small, but it is clean and bright.',
 'Dairesi üçüncü kattadır. Yedi numaralı dairedir. Anahtarı kapıya sokar. Kapıyı açar ve içeri girer. Daire küçüktür ama temiz ve aydınlıktır.',
 17, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'I love it. There is a small living room with a blue sofa. There is a small television. The kitchen is very clean. The bedroom has a big bed and a wardrobe. This is my new life.',
 'Buna bayıldım. Mavi kanepesi olan küçük bir oturma odası var. Küçük bir televizyon var. Mutfak çok temiz. Yatak odasında büyük bir yatak ve bir gardırop var. Bu benim yeni hayatım.',
 18, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'Suddenly, Anna hears a noise. Somebody is knocking on the door. Knock, knock, knock. Anna opens the door. There is a young man. He is wearing blue jeans and a white t-shirt. He is smiling.',
 'Aniden Anna bir ses duyar. Birisi kapıyı çalmaktadır. Tık, tık, tık. Anna kapıyı açar. Genç bir adam vardır. Mavi kot pantolon ve beyaz bir tişört giymektedir. Gülümsemektedir.',
 19, NOW()),

(gen_random_uuid(), ep_id, 'Ben', 0,
 'Hi! I am Ben. I live in apartment number eight. I am your neighbor. I saw you on the stairs with your heavy bags. Welcome to the building!',
 'Selam! Ben Ben. Sekiz numaralı dairede yaşıyorum. Ben senin komşunum. Seni merdivenlerde ağır çantalarınla gördüm. Binaya hoş geldin!',
 20, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Oh, hello! Nice to meet you. My name is Anna. I just moved here from a small village today. I am a little tired.',
 'Oh, merhaba! Tanıştığımıza memnun oldum. Benim adım Anna. Buraya daha bugün küçük bir köyden taşındım. Biraz yorgunum.',
 21, NOW()),

(gen_random_uuid(), ep_id, 'Ben', 0,
 'Nice to meet you, Anna. If you need anything, just knock on my door. There is a very good supermarket down the street. It is open until ten o''clock tonight.',
 'Tanıştığımıza memnun oldum Anna. Bir şeye ihtiyacın olursa, kapımı çalman yeterli. Sokağın aşağısında çok iyi bir süpermarket var. Bu gece saat ona kadar açık.',
 22, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Thank you, Ben. That is very kind. I will go to the supermarket later to buy some bread, milk, and cheese. See you later!',
 'Teşekkür ederim Ben. Bu çok nazikçe. Daha sonra biraz ekmek, süt ve peynir almak için süpermarkete gideceğim. Sonra görüşürüz!',
 23, NOW()),

-- SCENE 4: FINDING A JOB
(gen_random_uuid(), ep_id, 'Narrator', 0,
 'The next day is Tuesday. Anna wakes up at eight o''clock. She takes a shower and puts on a black skirt and a clean white shirt. She wants to find a job today. She takes her resume and walks out of her apartment.',
 'Ertesi gün Salı''dır. Anna saat sekizde uyanır. Duş alır, siyah bir etek ve temiz beyaz bir gömlek giyer. Bugün bir iş bulmak istemektedir. Özgeçmişini alır ve dairesinden çıkar.',
 24, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'Anna walks in the city center. She looks at the shops. She sees a big coffee shop. The sign says: "Star Cafe - We Need A Barista". Anna takes a deep breath and opens the door.',
 'Anna şehir merkezinde yürür. Dükkanlara bakar. Büyük bir kahve dükkanı görür. Tabelada "Star Cafe - Baristaya İhtiyacımız Var" yazmaktadır. Anna derin bir nefes alır ve kapıyı açar.',
 25, NOW()),

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'Hello! Welcome to Star Cafe. How can I help you today? Do you want a coffee?',
 'Merhaba! Star Cafe''ye hoş geldiniz. Bugün size nasıl yardımcı olabilirim? Kahve ister misiniz?',
 26, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Hello. No, thank you. I am looking for a job. I saw the sign in the window. My name is Anna. Are you the manager?',
 'Merhaba. Hayır, teşekkür ederim. İş arıyorum. Camdaki tabelayı gördüm. Adım Anna. Siz yönetici misiniz?',
 27, NOW()),

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'Yes, I am the manager. My name is Sarah. Nice to meet you, Anna. Do you have any experience? Have you worked in a cafe before?',
 'Evet, ben yöneticiyim. Adım Sarah. Tanıştığıma memnun oldum Anna. Hiç deneyiminiz var mı? Daha önce bir kafede çalıştınız mı?',
 28, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Yes, I have. In my village, I worked at a bakery for two years. I know how to make tea and coffee. I am friendly, I learn fast, and I can work on weekends.',
 'Evet, var. Köyümde iki yıl boyunca bir fırında çalıştım. Çay ve kahve yapmayı biliyorum. Arkadaş canlısıyım, hızlı öğrenirim ve hafta sonları çalışabilirim.',
 29, NOW()),

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'That is wonderful. We need a friendly person. The job pays twelve pounds an hour. You will work from nine in the morning to five in the afternoon. Can you start tomorrow?',
 'Bu harika. Arkadaş canlısı birine ihtiyacımız var. İş saatte on iki sterlin ödüyor. Sabah dokuzdan öğleden sonra beşe kadar çalışacaksınız. Yarın başlayabilir misiniz?',
 30, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Start tomorrow? Yes! Yes, I can start tomorrow. Thank you so much, Sarah. I am very happy.',
 'Yarın başlamak mı? Evet! Evet, yarın başlayabilirim. Çok teşekkür ederim Sarah. Çok mutluyum.',
 31, NOW()),

-- SCENE 5: THE FIRST DAY AT WORK
(gen_random_uuid(), ep_id, 'Narrator', 0,
 'On Wednesday, Anna starts her new job. The cafe is very busy. Many people come in the morning. They want coffee, croissants, and sandwiches. Anna is a little nervous, but Sarah helps her.',
 'Çarşamba günü Anna yeni işine başlar. Kafe çok yoğundur. Sabahları birçok insan gelmektedir. Kahve, kruvasan ve sandviç isterler. Anna biraz gergin ama Sarah ona yardım eder.',
 32, NOW()),

(gen_random_uuid(), ep_id, 'Customer', 0,
 'Excuse me. Can I have a large cappuccino and a chocolate muffin, please? How much is that?',
 'Afedersiniz. Büyük bir cappuccino ve çikolatalı muffin alabilir miyim lütfen? Ne kadar tutuyor?',
 33, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Of course. One large cappuccino and one chocolate muffin. That is six pounds and fifty pence, please. Do you want to pay with cash or a credit card?',
 'Elbette. Bir büyük cappuccino ve bir çikolatalı muffin. Altı sterlin elli peni lütfen. Nakit mi yoksa kredi kartıyla mı ödemek istersiniz?',
 34, NOW()),

(gen_random_uuid(), ep_id, 'Customer', 0,
 'I will pay with my credit card. Here you go. Thank you.',
 'Kredi kartımla ödeyeceğim. Buyurun. Teşekkür ederim.',
 35, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Thank you. Please wait a moment. Your coffee will be ready soon. Have a nice day!',
 'Teşekkür ederim. Lütfen bir an bekleyin. Kahveniz yakında hazır olacak. İyi günler dilerim!',
 36, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'The afternoon is quieter. Anna cleans the tables and washes the cups. Sarah smiles at her. "You are doing a great job, Anna," she says. Anna feels proud. She loves her new job.',
 'Öğleden sonra daha sakindir. Anna masaları temizler ve fincanları yıkar. Sarah ona gülümser. "Harika bir iş çıkarıyorsun Anna," der. Anna gurur duyar. Yeni işini sevmektedir.',
 37, NOW()),

-- SCENE 6: THE WEEKEND & THE LOST DOG
(gen_random_uuid(), ep_id, 'Narrator', 0,
 'It is Saturday. Anna does not work today. The weather is beautiful. The sun is shining, and it is warm. She walks out of her apartment. She sees her neighbor, Ben.',
 'Günlerden Cumartesi. Anna bugün çalışmıyor. Hava çok güzel. Güneş parlıyor ve hava ılık. Dairesinden çıkıyor. Komşusu Ben''i görüyor.',
 38, NOW()),

(gen_random_uuid(), ep_id, 'Ben', 0,
 'Good morning, Anna! How was your first week at the new job? Do you like living in London?',
 'Günaydın Anna! Yeni işindeki ilk haftan nasıldı? Londra''da yaşamayı seviyor musun?',
 39, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Good morning, Ben! Yes, I love it. My job is great, and the city is amazing. But I don''t know the city very well. I want to go for a walk today.',
 'Günaydın Ben! Evet, bayıldım. İşim harika ve şehir inanılmaz. Ama şehri çok iyi bilmiyorum. Bugün yürüyüşe çıkmak istiyorum.',
 40, NOW()),

(gen_random_uuid(), ep_id, 'Ben', 0,
 'Do you want to go to the big park? It is very close. We can walk together. I have a small dog named Toby. He needs a walk too.',
 'Büyük parka gitmek ister misin? Çok yakın. Birlikte yürüyebiliriz. Toby adında küçük bir köpeğim var. Onun da yürüyüşe ihtiyacı var.',
 41, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'That sounds lovely! I really like dogs. Let''s go.',
 'Kulağa hoş geliyor! Köpekleri gerçekten severim. Haydi gidelim.',
 42, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'They walk to the park. The park is very big and green. Children are playing football. Birds are singing. Ben takes the ball and throws it. Toby runs fast to catch the ball. Suddenly, Toby runs behind some trees.',
 'Parka yürürler. Park çok büyük ve yeşildir. Çocuklar futbol oynamaktadır. Kuşlar şarkı söylemektedir. Ben topu alır ve fırlatır. Toby topu yakalamak için hızlıca koşar. Aniden Toby ağaçların arkasına doğru koşar.',
 43, NOW()),

(gen_random_uuid(), ep_id, 'Ben', 0,
 'Toby! Come back here! Toby! Oh no, where is he? I can''t see him. He is very small, and he runs very fast.',
 'Toby! Buraya geri dön! Toby! Olamaz, nerede o? Onu göremiyorum. O çok küçük ve çok hızlı koşuyor.',
 44, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Don''t panic, Ben. Let''s look for him. You go to the left, near the lake. I will go to the right, near the playground. We will find him.',
 'Paniğe kapılma Ben. Onu arayalım. Sen gölün yanına, sola git. Ben oyun alanının yanına, sağa gideceğim. Onu bulacağız.',
 45, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'Anna walks near the playground. She looks under the benches. She looks behind the big trees. Then, she hears a small sound. "Woof, woof." She looks down. Toby is sitting next to a little girl. He is eating a piece of sandwich.',
 'Anna oyun alanının yakınında yürür. Bankların altına bakar. Büyük ağaçların arkasına bakar. Sonra küçük bir ses duyar. "Hav, hav." Aşağı bakar. Toby küçük bir kızın yanında oturmaktadır. Bir parça sandviç yemektedir.',
 46, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'Toby! There you are! You bad boy, you ran away for food. Come here.',
 'Toby! Buradasın! Seni yaramaz çocuk, yemek için kaçtın. Gel buraya.',
 47, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'Anna picks up the dog and walks back to Ben. Ben is very happy to see his dog. He hugs Toby and thanks Anna.',
 'Anna köpeği kucağına alır ve Ben''e doğru geri yürür. Ben köpeğini gördüğüne çok sevinir. Toby''ye sarılır ve Anna''ya teşekkür eder.',
 48, NOW()),

(gen_random_uuid(), ep_id, 'Ben', 0,
 'Thank you so much, Anna. You are a lifesaver. I was so worried. To say thank you, I want to cook dinner for you tonight. Do you like pasta?',
 'Çok teşekkür ederim Anna. Sen bir hayat kurtarıcısın. Çok endişelenmiştim. Teşekkür etmek için bu gece sana akşam yemeği pişirmek istiyorum. Makarna sever misin?',
 49, NOW()),

(gen_random_uuid(), ep_id, 'Anna', 1,
 'I love pasta! That is very nice of you. I will bring some dessert from the bakery.',
 'Makarnaya bayılırım! Bu çok hoş bir davranış. Fırından biraz tatlı getireceğim.',
 50, NOW()),

-- SCENE 7: A HAPPY ENDING
(gen_random_uuid(), ep_id, 'Narrator', 0,
 'That evening, Anna and Ben eat dinner together. They talk about their families, their jobs, and their dreams. Anna smiles. She thinks about her small village. She misses her parents, but she is very happy.',
 'O akşam Anna ve Ben birlikte akşam yemeği yerler. Aileleri, işleri ve hayalleri hakkında konuşurlar. Anna gülümser. Küçük köyünü düşünür. Anne babasını özlemektedir ama çok mutludur.',
 51, NOW()),

(gen_random_uuid(), ep_id, 'Narrator', 0,
 'She has a nice apartment. She has a good job. She has a new friend. London is a big and noisy city, but it is her new home. Anna''s new life is just beginning.',
 'Güzel bir dairesi vardır. İyi bir işi vardır. Yeni bir arkadaşı vardır. Londra büyük ve gürültülü bir şehirdir ama artık onun yeni evidir. Anna''nın yeni hayatı daha yeni başlamaktadır.',
 52, NOW());

RAISE NOTICE 'Episode ID: %', ep_id;

END $$;
