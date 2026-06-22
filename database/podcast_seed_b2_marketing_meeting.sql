-- ============================================================
-- Podcast Episode: A Marketing Strategy Meeting (B2)
-- Karakterler: Sarah (Female) & Alex (Male)
-- Çalıştırma: psql veya pgAdmin ile doğrudan uygulayın
-- ÖNEMLİ: Önce podcast_create_tables.sql çalıştırın
-- ============================================================

DO $$
DECLARE
    ep_id uuid;
BEGIN
    ep_id := gen_random_uuid();

-- Episode kaydı
INSERT INTO podcast_episodes ("Id", "Title", "Description", "EnglishLevel", "DisplayOrder", "IsActive", "CreatedAt")
VALUES (
    ep_id,
    'A Marketing Strategy Meeting',
    'Alex has just started a new job. He leads a detailed strategy meeting with his team for the launch of a new educational software called EduPro 360.',
    4,   -- B2
    1,
    TRUE,
    NOW()
);

-- Satırlar (DisplayOrder sırası önemli)
-- SpeakerGender: 0 = Male, 1 = Female

INSERT INTO podcast_lines ("Id", "EpisodeId", "SpeakerName", "SpeakerGender", "Text", "TranslationTr", "DisplayOrder", "CreatedAt")
VALUES

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'Good morning, everyone. Please grab a coffee and let''s get started. Today''s agenda is critical. As you know, our new educational software, EduPro 360, is launching in exactly six weeks. Alex, since you are leading the marketing strategy for this product, the floor is yours.',
 'Günaydın herkese. Bir kahve alın ve başlayalım. Bugünkü gündem çok kritik. Bildiğiniz gibi yeni eğitim yazılımımız EduPro 360, tam olarak altı hafta sonra piyasaya çıkıyor. Alex, bu ürünün pazarlama stratejisini sen yönettiğin için söz sende.',
 1, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 0,
 'Thank you, Sarah. Good morning, team. Over the past two weeks, I have conducted a comprehensive analysis of our target audience. EduPro 360 is designed for high school teachers and school administrators. Therefore, running generic ads on Facebook or Instagram won''t give us the results we want. We need a highly targeted B2B approach.',
 'Teşekkürler Sarah. Günaydın ekip. Son iki haftada hedef kitlemizi kapsamlı biçimde analiz ettim. EduPro 360, lise öğretmenleri ve okul yöneticileri için tasarlandı. Bu nedenle Facebook veya Instagram''da genel reklamlar vermek istediğimiz sonuçları vermeyecek. Yüksek hedefli bir B2B yaklaşımına ihtiyacımız var.',
 2, NOW()),

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'I agree. Teachers are busy professionals. How do you plan to grab their attention effectively without being ignored as just another spam advertisement?',
 'Katılıyorum. Öğretmenler meşgul profesyoneller. Sıradan bir spam reklamı gibi görmezden gelinmeden dikkatlerini nasıl çekmeyi planlıyorsun?',
 3, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 0,
 'I propose a two-phase strategy. Phase one is an educational email drip campaign, and phase two is a live, interactive webinar. Instead of just trying to sell the software, we should offer them something valuable for free. We can create a downloadable PDF guide called The Future of Digital Classrooms. To download it, they have to provide their email addresses.',
 'İki aşamalı bir strateji öneriyorum. Birinci aşama eğitici bir e-posta damlatma kampanyası, ikinci aşama ise canlı ve interaktif bir web semineri. Yazılımı satmaya çalışmak yerine onlara ücretsiz değerli bir şey sunmalıyız. Dijital Sınıfların Geleceği adlı indirilebilir bir PDF rehberi oluşturabiliriz. İndirmek için e-posta adreslerini vermeleri gerekecek.',
 4, NOW()),

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'So, we use the PDF guide as a lead magnet to build our email list. That is a solid inbound marketing tactic. But how do we drive traffic to the download page in the first place?',
 'Yani e-posta listemizi oluşturmak için PDF rehberi bir mıknatıs olarak kullanıyoruz. Bu sağlam bir içe dönük pazarlama taktiği. Ama indirme sayfasına ilk etapta nasıl trafik çekeceğiz?',
 5, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 0,
 'We will utilize LinkedIn Advertising. We can filter our ads to specifically target people whose job titles are High School Teacher or Principal. Once they download the guide, they enter our email sequence. Over the next two weeks, we will send them three emails detailing how our software solves their specific classroom problems.',
 'LinkedIn Reklamcılığını kullanacağız. Reklamlarımızı Lise Öğretmeni veya Okul Müdürü unvanına sahip kişileri hedefleyecek şekilde filtreleyebiliriz. Rehberi indirdiklerinde e-posta dizimize girerler. Sonraki iki hafta içinde onlara yazılımımızın sınıf sorunlarını nasıl çözdüğünü anlatan üç e-posta göndereceğiz.',
 6, NOW()),

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'And the final email invites them to the webinar?',
 'Ve son e-posta onları web seminerine davet ediyor mu?',
 7, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 0,
 'Exactly. The webinar will feature a live demonstration of EduPro 360. They can ask questions, see the interface, and understand the value directly from our product developers. Furthermore, anyone who purchases a yearly subscription during the webinar will receive a twenty percent early-bird discount.',
 'Kesinlikle. Web semineri EduPro 360''ın canlı bir demosunu içerecek. Soru sorabilir, arayüzü görebilir ve ürünümüzün değerini doğrudan geliştiricilerden anlayabilirler. Ayrıca web semineri sırasında yıllık abonelik satın alan herkes yüzde yirmi erken kayıt indirimi alacak.',
 8, NOW()),

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'I really like the structure of this funnel. However, six weeks is a very tight deadline for all of this. We need to create the PDF guide, design the landing pages, write the email copies, and set up the webinar software. Are you confident we can deliver this on time?',
 'Bu dönüşüm hunisinin yapısını gerçekten çok beğendim. Ancak tüm bunlar için altı hafta çok sıkı bir son tarih. PDF rehberini oluşturmamız, açılış sayfalarını tasarlamamız, e-posta metinlerini yazmamız ve web semineri yazılımını kurmamız gerekiyor. Bunu zamanında teslim edebileceğimizden emin misin?',
 9, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 0,
 'It will require everyone to be on the same page, but yes, it is absolutely feasible. I have already drafted the outline for the PDF guide. If the design team can finalize the graphics by this Friday, the copywriting team can finish the landing pages by next Tuesday.',
 'Herkesin aynı fikirde olmasını gerektirecek ama evet, kesinlikle yapılabilir. PDF rehberin taslağını zaten hazırladım. Tasarım ekibi görselleri bu Cuma''ya kadar tamamlayabilirse, metin yazma ekibi açılış sayfalarını gelecek Salı''ya kadar bitirebilir.',
 10, NOW()),

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'What about the budget for the LinkedIn campaign? LinkedIn ads are notoriously more expensive than other platforms.',
 'LinkedIn kampanyasının bütçesi ne olacak? LinkedIn reklamlarının diğer platformlardan çok daha pahalı olduğu herkesce biliniyor.',
 11, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 0,
 'They are more expensive per click, but the conversion rate for B2B software is significantly higher. I am requesting an initial budget of eight thousand dollars for the first two weeks. We will run A/B testing on two different ad visuals. After we see which ad performs better, we will allocate the remaining twelve thousand dollars to the winning advertisement.',
 'Tıklama başına daha pahalı ama B2B yazılım için dönüşüm oranı çok daha yüksek. İlk iki hafta için sekiz bin dolarlık başlangıç bütçesi talep ediyorum. İki farklı reklam görseli üzerinde A/B testi yapacağız. Hangi reklamın daha iyi performans gösterdiğini gördükten sonra kalan on iki bin doları kazanan reklama ayıracağız.',
 12, NOW()),

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'An overall budget of twenty thousand dollars is within our quarterly limits. I approve the budget. However, I want a weekly progress report on my desk every Friday afternoon. I need to see the cost per lead and the click-through rates.',
 'Toplam yirmi bin dolarlık bütçe üç aylık limitimiz dahilinde. Bütçeyi onaylıyorum. Ancak her Cuma öğleden sonra masamda haftalık bir ilerleme raporu görmek istiyorum. Müşteri başına maliyeti ve tıklama oranlarını görmem gerekiyor.',
 13, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 0,
 'Understood. I will set up an automated dashboard on Google Analytics so you can monitor the real-time performance at any moment. I will also schedule a brief alignment meeting with the design and copy teams this afternoon to assign specific deadlines.',
 'Anlaşıldı. Google Analytics''te otomatik bir gösterge paneli kuracağım, böylece gerçek zamanlı performansı istediğiniz zaman takip edebilirsiniz. Bu öğleden sonra tasarım ve metin ekipleriyle kısa bir uyum toplantısı da planlayacağım.',
 14, NOW()),

(gen_random_uuid(), ep_id, 'Sarah', 1,
 'Excellent work, Alex. It seems like you have thought of every detail. Let''s make this our most successful launch of the year. If anyone needs additional resources, please let me know. Meeting adjourned.',
 'Mükemmel çalışma Alex. Her ayrıntıyı düşünmüş gibisin. Bunu yılın en başarılı lansmanı yapalım. Ek kaynaklara ihtiyacı olan herkes bana bildirsin. Toplantı sona erdi.',
 15, NOW());

RAISE NOTICE 'Episode ID: %', ep_id;

END $$;
