-- ============================================================
-- Podcast Episode: The Job Interview (B2)
-- Karakterler: Mr. Davis (Male) & Alex (Female)
-- NOT: Alex ismi unisex; TTS'de iki farklı ses almak için Female atandı.
-- Çalıştırma: psql veya pgAdmin ile doğrudan uygulayın
-- ÖNEMLİ: Önce podcast_create_tables.sql çalıştırılmış olmalı
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
    'The Job Interview',
    'Alex is interviewing for a Marketing Manager position at TechNova. In a detailed conversation with HR Director Mr. Davis, she discusses her career background, campaign experience, and leadership skills.',
    4,   -- B2
    2,
    TRUE,
    NOW()
);

-- Satırlar (DisplayOrder sırası önemli)
-- SpeakerGender: 0 = Male, 1 = Female

INSERT INTO podcast_lines ("Id", "EpisodeId", "SpeakerName", "SpeakerGender", "Text", "TranslationTr", "DisplayOrder", "CreatedAt")
VALUES

(gen_random_uuid(), ep_id, 'Mr. Davis', 0,
 'Good afternoon, Alex. I''m Richard Davis, the Director of Human Resources, and joining us virtually on the screen is Emma Lewis, our Head of Marketing. Please, have a seat.',
 'İyi günler Alex. Ben Richard Davis, İnsan Kaynakları Direktörü. Ekranda bize sanal olarak katılan kişi ise Pazarlama Müdürümüz Emma Lewis. Lütfen oturun.',
 1, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 1,
 'Good afternoon, Mr. Davis. Good afternoon, Emma. Thank you both for inviting me to this interview. I have been following TechNova''s projects for a long time, so it is a real privilege to be here.',
 'İyi günler Bay Davis. İyi günler Emma. İkinize de beni bu mülakata davet ettiğiniz için teşekkür ederim. TechNova''nın projelerini uzun süredir takip ediyorum, bu yüzden burada olmak gerçekten bir ayrıcalık.',
 2, NOW()),

(gen_random_uuid(), ep_id, 'Mr. Davis', 0,
 'We appreciate your interest. Let''s dive right in. Your resume highlights a very strong background in digital advertising. However, transitioning from a mid-sized agency to a large corporate environment like TechNova can be challenging. Why do you think you are the right fit for this specific transition?',
 'İlginizi takdir ediyoruz. Hemen konuya girelim. Özgeçmişiniz dijital reklamcılıkta çok güçlü bir altyapıya sahip olduğunuzu gösteriyor. Ancak orta ölçekli bir ajandan TechNova gibi büyük bir kurumsal ortama geçiş zorlu olabilir. Bu özel geçiş için neden doğru aday olduğunuzu düşünüyorsunuz?',
 3, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 1,
 'That is a very valid point. While my previous company was smaller, I was responsible for managing accounts that operated on a national level. Because the team was small, I had to wear multiple hats. I handled strategy, budget allocation, and data analysis simultaneously. This taught me how to be highly adaptable and resilient under pressure, which I believe are essential qualities for a fast-paced corporate environment.',
 'Bu çok geçerli bir nokta. Önceki şirketim daha küçük olsa da ulusal düzeyde faaliyet gösteren hesapları yönetmekten sorumluydım. Ekip küçük olduğu için birçok farklı rol üstlenmek zorunda kaldım. Strateji, bütçe tahsisi ve veri analizini eş zamanlı olarak yürüttüm. Bu deneyim bana baskı altında son derece uyumlu ve dirençli olmayı öğretti; bunların hızlı tempolu bir kurumsal ortam için temel nitelikler olduğuna inanıyorum.',
 4, NOW()),

(gen_random_uuid(), ep_id, 'Mr. Davis', 0,
 'Adaptability is indeed crucial here. Emma and I were looking at your portfolio, specifically the Summer Wave campaign. Can you walk us through your thought process for that project? What was the biggest obstacle you faced?',
 'Uyum yeteneği burada gerçekten çok önemli. Emma ile portföyünüze, özellikle de Summer Wave kampanyasına baktık. Bize o proje için düşünce sürecinizi anlatabilir misiniz? Karşılaştığınız en büyük engel neydi?',
 5, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 1,
 'Certainly. The main objective of the Summer Wave campaign was to increase brand awareness among university students. The biggest obstacle was our limited budget. Traditional advertising was simply too expensive. Therefore, I decided to pivot our strategy entirely towards micro-influencers on TikTok and Instagram.',
 'Elbette. Summer Wave kampanyasının temel amacı üniversite öğrencileri arasında marka bilinirliğini artırmaktı. En büyük engel sınırlı bütçemizdi. Geleneksel reklamcılık basitçe çok pahalıydı. Bu nedenle stratejimizi tamamen TikTok ve Instagram''daki mikro influencer''lara yönlendirmeye karar verdim.',
 6, NOW()),

(gen_random_uuid(), ep_id, 'Mr. Davis', 0,
 'Micro-influencers? That is an interesting approach. Why didn''t you aim for larger, more famous influencers?',
 'Mikro influencer''lar mı? Bu ilginç bir yaklaşım. Neden daha büyük, daha tanınmış influencer''ları hedeflemediniz?',
 7, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 1,
 'Research shows that micro-influencers usually have a much higher engagement rate with their followers. They feel more authentic and trustworthy to their audience. By collaborating with twenty micro-influencers instead of one major celebrity, we achieved a forty percent higher Return on Investment and exceeded our sales target by fifteen percent.',
 'Araştırmalar, mikro influencer''ların takipçileriyle genellikle çok daha yüksek etkileşim oranına sahip olduğunu gösteriyor. Kitleleri için daha özgün ve güvenilir hissettiriyorlar. Bir büyük ünlü yerine yirmi mikro influencer ile iş birliği yaparak yüzde kırk daha yüksek yatırım getirisi elde ettik ve satış hedefimizi yüzde on beş aştık.',
 8, NOW()),

(gen_random_uuid(), ep_id, 'Mr. Davis', 0,
 'That is a very strategic and data-driven approach. I like that. Now, let''s talk about team dynamics. As a Marketing Manager, you will be leading a team of five people. Tell me about a time you had to deal with a difficult team member or a conflict in the workplace.',
 'Bu çok stratejik ve veri odaklı bir yaklaşım. Bunu beğendim. Şimdi ekip dinamiklerinden konuşalım. Pazarlama Müdürü olarak beş kişilik bir ekibi yöneteceksiniz. Bana zor bir ekip üyesiyle ya da iş yerindeki bir çatışmayla başa çıkmak zorunda kaldığınız bir zamanı anlatın.',
 9, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 1,
 'In my previous role, I had a graphic designer who was incredibly talented but consistently missed deadlines. This was causing a bottleneck for the whole marketing department. Instead of officially reprimanding him immediately, I scheduled a private, informal meeting to understand the root of the problem.',
 'Önceki görevimde inanılmaz yetenekli ama sürekli son tarihleri kaçıran bir grafik tasarımcım vardı. Bu, tüm pazarlama departmanı için bir darboğaza neden oluyordu. Onu hemen resmi olarak uyarmak yerine sorunun kökenini anlamak için özel, gayri resmi bir toplantı planladım.',
 10, NOW()),

(gen_random_uuid(), ep_id, 'Mr. Davis', 0,
 'And what did you discover during that meeting?',
 'Peki o toplantıda ne keşfettiniz?',
 11, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 1,
 'It turned out he was overwhelmed because he was receiving tasks from three different departments without a proper priority list. To solve this, I implemented a centralized task management system using Trello. I also became the sole person to approve his deadlines. His productivity improved drastically within two weeks, and the team conflict was completely resolved.',
 'Düzgün bir öncelik listesi olmadan üç farklı departmandan görev aldığı için bunaldığı ortaya çıktı. Bunu çözmek için Trello kullanarak merkezi bir görev yönetim sistemi kurdum. Ayrıca son tarihleri onaylayan tek kişi ben oldum. Verimliliği iki hafta içinde dramatik biçimde arttı ve ekip çatışması tamamen çözüldü.',
 12, NOW()),

(gen_random_uuid(), ep_id, 'Mr. Davis', 0,
 'Excellent conflict resolution skills. Empathy combined with a practical system is exactly the kind of leadership we encourage at TechNova. Do you have any questions for us?',
 'Mükemmel çatışma çözüm becerileri. Pratik bir sistemle birleşmiş empati, TechNova''da teşvik ettiğimiz tam da bu tür bir liderlik. Bize sormak istediğiniz sorular var mı?',
 13, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 1,
 'Yes, I do. If I were to be hired for this position, what would be my primary focus during the first thirty days?',
 'Evet, var. Bu pozisyon için işe alınsaydım, ilk otuz günde birincil odak noktam ne olurdu?',
 14, NOW()),

(gen_random_uuid(), ep_id, 'Mr. Davis', 0,
 'We are launching a new educational software in three months. Your primary focus would be to audit our current marketing channels, integrate yourself with the team, and draft a preliminary launch strategy. We expect our managers to take initiative early on.',
 'Üç ay içinde yeni bir eğitim yazılımı piyasaya sürüyoruz. Birincil odak noktanız mevcut pazarlama kanallarımızı denetlemek, ekiple kaynaşmak ve ön bir lansman stratejisi taslağı hazırlamak olurdu. Yöneticilerimizin başından itibaren inisiyatif almalarını bekliyoruz.',
 15, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 1,
 'That sounds like an exciting challenge, and I am definitely ready for it.',
 'Bu heyecan verici bir meydan okuma gibi geliyor ve kesinlikle bunun için hazırım.',
 16, NOW()),

(gen_random_uuid(), ep_id, 'Mr. Davis', 0,
 'Perfect. We are interviewing a few more candidates this week, but we will make our final decision by next Wednesday. Thank you for coming in, Alex.',
 'Mükemmel. Bu hafta birkaç aday daha görüşüyoruz, ancak nihai kararımızı gelecek Çarşamba''ya kadar vereceğiz. Geldiğiniz için teşekkür ederiz, Alex.',
 17, NOW()),

(gen_random_uuid(), ep_id, 'Alex', 1,
 'Thank you for your time, Mr. Davis. I look forward to hearing from you.',
 'Zamanınız için teşekkür ederim Bay Davis. Sizden haber bekliyorum.',
 18, NOW());

RAISE NOTICE 'Episode ID: %', ep_id;

END $$;
