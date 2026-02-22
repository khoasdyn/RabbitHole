import Foundation
import SwiftData

// MARK: - Level 1: Newcomer
// "Were the Stoics right that most of your problems are imaginary?"

struct StoicismMockContent {

    static func seedLevel1(topic: Topic, context: ModelContext) {

        let items: [(type: String, title: String, subtitle: String?, body: String?, minutes: Int?, order: Int)] = [

            // 1 — Article
            (
                ContentType.article.rawValue,
                "Your flight got cancelled. The Stoics would say that's not a problem.",
                "The core idea that started a 2,000-year-old argument",
                """
                Imagine your flight just got cancelled. You're stuck at the airport for eight hours. Most people would say that's a problem. The Stoics would disagree.

                Around 300 BC in Athens, a merchant named Zeno lost everything in a shipwreck. Instead of spiraling, he wandered into a bookshop, discovered philosophy, and eventually founded an entire school of thought on a simple radical idea: the things that happen to you are not the problem. Your judgments about those things are.

                This is the core of Stoicism. Not that bad things don't happen, but that your reaction to them is where suffering actually lives. The cancelled flight isn't painful. Your belief that it shouldn't have been cancelled, that your evening is ruined, that the airline is terrible — that's where the pain comes from.

                The Stoics called this the "dichotomy of control." Every situation has two parts: what you can control (your thoughts, your actions, your attitude) and what you can't (other people, weather, delays, illness, death). Suffering comes from trying to control the second category.

                Marcus Aurelius, who was literally the Roman Emperor and could have had anything he wanted, wrote in his private journal: "You have power over your mind, not outside events. Realize this, and you will find strength." He wasn't writing self-help. He was reminding himself, during plagues and wars, that his mental response was the only thing truly his.

                This doesn't mean Stoics were emotionless robots. That's a common misconception. They felt sadness, joy, and frustration like everyone else. The difference is they trained themselves not to be controlled by those feelings. They made a distinction between a "first impression" (the automatic gut reaction) and "assent" (choosing to believe that reaction is true).

                You feel the flash of anger when your flight is cancelled. That's natural. But the Stoic practice is to pause before the next step — before you decide this ruins your day, before you yell at the gate agent, before you catastrophize. In that pause, you ask: is this actually in my control? And if not, why am I treating it as though it is?

                It's a deceptively simple idea. And as you'll discover going deeper, it gets much more nuanced and debatable. But this is where it starts: the claim that most of your problems exist in the gap between what happened and what you think should have happened.
                """,
                5,
                1
            ),

            // 2 — Article
            (
                ContentType.article.rawValue,
                "Marcus Aurelius wrote a journal no one was supposed to read",
                "The most powerful man in the world talking himself through bad days",
                """
                Marcus Aurelius was the Emperor of Rome from 161 to 180 AD. He commanded armies, managed a vast empire, and dealt with plague, betrayal, and constant war. He was arguably the most powerful person alive.

                And every night, he sat down and wrote in a journal. Not for publication. Not for posterity. For himself. He was essentially writing therapy notes, reminding himself how to think, how to stay grounded, how not to lose his mind under the weight of ruling the known world.

                That journal survived. We call it "Meditations" today, and it's one of the most widely read philosophy books in history. But it was never meant to be a book. It's raw, repetitive, sometimes contradictory. He writes the same lessons over and over because he kept needing to remind himself.

                "When you wake up in the morning, tell yourself: the people I deal with today will be meddling, ungrateful, arrogant, dishonest, jealous, and surly." That's not cynicism. It's preparation. He's saying: don't be surprised by difficult people. Expect them. And then choose how you respond.

                What makes Meditations so striking is the gap between his power and his humility. This is a man who could have anyone executed, yet he's writing notes about patience and self-control. He didn't think being emperor exempted him from doing the inner work. If anything, he thought it made the work more urgent.

                The Stoic lesson here isn't about journaling (though that helps). It's that no external circumstance — not even unlimited power and wealth — solves the internal challenge of how you relate to your own mind. Marcus had everything, and he still had to practice not being overwhelmed by his own thoughts.

                That's a pretty strong argument for the Stoic claim that your problems are mostly internal. If the richest, most powerful man in the ancient world still struggled with the same mental patterns you do, maybe the problem really isn't your circumstances.
                """,
                4,
                2
            ),

            // 3 — Quiz
            (
                ContentType.quiz.rawValue,
                "Do you actually get what the Stoics were saying?",
                "3 questions to check your understanding",
                """
                {"questions":[{"question":"A Stoic would say suffering comes from...","options":["Bad events happening to you","Your judgments about events","Not having enough willpower","Ignoring your emotions"],"correctIndex":1,"explanation":"The Stoics argued that events themselves are neutral. Suffering comes from the judgments and beliefs we attach to them."},{"question":"The 'dichotomy of control' divides situations into...","options":["Good and bad outcomes","Past and future events","What you can and can't control","Emotions and logic"],"correctIndex":2,"explanation":"The dichotomy of control separates what is 'up to us' (our thoughts, actions, attitudes) from what is 'not up to us' (everything external)."},{"question":"Marcus Aurelius wrote Meditations as...","options":["A bestselling philosophy book","A guide for future emperors","Private notes to himself","Letters to his Stoic teacher"],"correctIndex":2,"explanation":"Meditations was never intended for publication. It was Marcus Aurelius's personal journal, essentially therapy notes he wrote to keep himself grounded."}]}
                """,
                3,
                3
            ),

            // 4 — Discussion
            (
                ContentType.discussion.rawValue,
                "Your best friend just got dumped and is devastated. A Stoic would say the pain is self-created. Would you tell them that?",
                "A conversation about when Stoic ideas help and when they might hurt",
                """
                {"exchanges":[{"role":"prompt","text":"Your best friend just got dumped and is devastated. A Stoic would say the heartbreak is caused by their judgments, not the breakup itself. Would you actually say that to them?"},{"role":"follow_up_1","text":"That's a thoughtful take. But here's the tension: if the Stoic framework is true, wouldn't a real friend help them see it? Or is there a difference between what's philosophically true and what's helpful to say in the moment?"},{"role":"follow_up_2","text":"Interesting. So you're drawing a line between understanding Stoicism yourself and prescribing it to others in pain. Do you think the Stoics themselves would agree with that distinction, or would they push back?"},{"role":"closing","text":"This is actually one of the oldest critiques of Stoicism — that it can feel cold when applied to real human grief. We'll explore this tension more as you go deeper. For now, it's worth sitting with the question: can an idea be true and still be the wrong thing to say?"}]}
                """,
                5,
                4
            ),

            // 5 — Article
            (
                ContentType.article.rawValue,
                "Epictetus was born a slave. He said that made him more free, not less.",
                "The Stoic who turned powerlessness into philosophy",
                """
                Epictetus was born around 50 AD as a slave in the Roman Empire. His master was Epaphroditus, a wealthy secretary to Emperor Nero. According to one account, Epaphroditus once twisted Epictetus's leg so brutally that it broke and left him permanently lame. Epictetus reportedly said during the act, calmly: "You're going to break it." And after it broke: "Didn't I tell you?"

                Whether that story is literal or legendary, it captures something real about his philosophy. Epictetus had no control over his body, his freedom, or his circumstances. But he built an entire philosophical system around the idea that none of that mattered — because the only thing truly "his" was his mind.

                His most famous teaching is deceptively simple: "It's not things that upset us, but our opinions about things." Your boss yells at you — that's an event. You decide it means you're a failure — that's your opinion, and that's where the suffering actually lives.

                After gaining his freedom, Epictetus became a teacher. He never wrote anything down. Everything we have from him was recorded by his student Arrian, in a collection called the Discourses. His classroom style was direct, confrontational, and often funny. He'd challenge students with real scenarios and force them to apply the dichotomy of control on the spot.

                What makes Epictetus especially relevant to the question of whether your problems are "imaginary" is his starting point. He didn't come to Stoicism from a place of comfort. He wasn't a wealthy Roman choosing philosophy as an intellectual hobby. He was someone who had genuine, undeniable hardship — slavery, disability, poverty — and still concluded that his real problems were internal, not external.

                You can disagree with that conclusion. Many people do. But it's hard to dismiss it as naive when it comes from someone who had every reason to blame his circumstances.
                """,
                5,
                5
            ),

            // 6 — Challenge
            (
                ContentType.challenge.rawValue,
                "Pick one thing bothering you right now. Split it in two.",
                "Try the dichotomy of control on something real from your day",
                """
                {"instructions":"Think of something that's been on your mind today — something stressful, annoying, or worrying. Write it down, then split it into two columns: what you can actually control about this situation, and what you can't. Be honest. Most people find the 'can't control' column is longer than expected.","completionPrompt":"I completed the exercise"}
                """,
                5,
                6
            )
        ]

        for item in items {
            let contentItem = ContentItem(
                type: item.type,
                level: 1,
                title: item.title,
                subtitle: item.subtitle,
                body: item.body,
                estimatedMinutes: item.minutes,
                sortOrder: item.order
            )
            contentItem.topic = topic
            context.insert(contentItem)
        }
    }
}
