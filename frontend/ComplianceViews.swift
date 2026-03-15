import SwiftUI

// MARK: - Privacy Policy View

struct PrivacyPolicyFullView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy Policy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        Text("Last updated: March 2024")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.slate600)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Section("1. Introduction") {
                            Text("CreatorBridge (\"we\", \"us\", \"our\") operates the CreatorBridge application. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application, including all related features, functionality, and services offered through the application.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("2. Information We Collect") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("We may collect information about you in a variety of ways. The information we may collect on the application includes:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("Personal identification information (name, email address, phone number)")
                                BulletPoint("Profile information (bio, interests, expertise areas)")
                                BulletPoint("Payment information (processed securely through third-party providers)")
                                BulletPoint("Communication data (messages, support tickets)")
                                BulletPoint("Device information (device type, OS version, unique identifiers)")
                                BulletPoint("Usage analytics (features used, frequency, duration)")
                                BulletPoint("Location data (with your permission)")
                            }
                        }
                        
                        Section("3. Use of Information") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("We use the information we collect to:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("Provide, maintain, and improve our services")
                                BulletPoint("Process transactions and send related information")
                                BulletPoint("Send promotional communications (with consent)")
                                BulletPoint("Respond to inquiries and provide customer support")
                                BulletPoint("Analyze usage patterns to improve user experience")
                                BulletPoint("Detect and prevent fraudulent activity")
                                BulletPoint("Comply with legal obligations")
                            }
                        }
                        
                        Section("4. Data Protection") {
                            Text("We implement appropriate technical and organizational measures designed to protect personal information against unauthorized access, alteration, disclosure or destruction. However, no method of transmission over the Internet is 100% secure.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("5. Third-Party Disclosure") {
                            Text("We do not sell, trade, or rent your personal information to third parties. However, we may share information with service providers who assist us in operating our application and conducting our business, subject to confidentiality agreements.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("6. Your Rights") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("You have the right to:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("Access your personal data")
                                BulletPoint("Correct inaccurate information")
                                BulletPoint("Request deletion of your information")
                                BulletPoint("Opt-out of marketing communications")
                                BulletPoint("Data portability")
                                BulletPoint("Lodge a complaint with authorities")
                            }
                        }
                        
                        Section("7. Cookies and Tracking") {
                            Text("Our application uses analytics and tracking technologies to understand user behavior. You can control these settings through your device preferences.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("8. Contact Us") {
                            Text("If you have questions about this Privacy Policy, please contact us at privacy@creatorbridge.com")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                        }
                    }
                }
                .padding(20)
            }
            .background(
                colorScheme == .dark ?
                AppTheme.slate900 : Color.white
            )
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Terms of Service View

struct TermsOfServiceFullView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Terms of Service")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        Text("Last updated: March 2024")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.slate600)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Section("1. Agreement to Terms") {
                            Text("By accessing and using CreatorBridge, you accept and agree to be bound by the terms and provision of this agreement.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("2. Use License") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Permission is granted to temporarily download one copy of the materials (information or software) on CreatorBridge for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("Modify or copy the materials")
                                BulletPoint("Use the materials for any commercial purpose or for any public display")
                                BulletPoint("Attempt to decompile or reverse engineer software")
                                BulletPoint("Remove any copyright or proprietary notations")
                                BulletPoint("Transfer materials to another person or \"mirror\" materials on any other server")
                            }
                        }
                        
                        Section("3. Disclaimer") {
                            Text("The materials on CreatorBridge are provided on an 'as is' basis. CreatorBridge makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("4. Limitations") {
                            Text("In no event shall CreatorBridge or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on CreatorBridge.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("5. Accuracy of Materials") {
                            Text("The materials appearing on CreatorBridge could include technical, typographical, or photographic errors. CreatorBridge does not warrant that any of the materials on its application are accurate, complete, or current. CreatorBridge may make changes to the materials contained on its application at any time without notice.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("6. Links") {
                            Text("CreatorBridge has not reviewed all of the sites linked to our application and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by CreatorBridge of the site. Use of any such linked website is at the user's own risk.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("7. Modifications") {
                            Text("CreatorBridge may revise these terms of service for its application at any time without notice. By using this application, you are agreeing to be bound by the then current version of these terms of service.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("8. Governing Law") {
                            Text("These terms and conditions are governed by and construed in accordance with the laws of the jurisdiction in which our headquarters is located, and you irrevocably submit to the exclusive jurisdiction of the courts in that location.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("9. User Accounts") {
                            Text("If you create an account on CreatorBridge, you are responsible for maintaining the confidentiality of your account information and password. You are responsible for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("10. Prohibited Conduct") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("You agree not to:")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.slate900)
                                
                                BulletPoint("Violate any applicable laws or regulations")
                                BulletPoint("Engage in any form of harassment or abuse")
                                BulletPoint("Post misleading, false, or deceptive content")
                                BulletPoint("Attempt to gain unauthorized access")
                                BulletPoint("Interfere with service operations")
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(
                colorScheme == .dark ?
                AppTheme.slate900 : Color.white
            )
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Community Guidelines View

struct CommunityGuidelinesView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Community Guidelines")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        Text("Help us keep CreatorBridge safe and respectful")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.slate600)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        GuidelineSection(
                            title: "1. Respectful Communication",
                            points: [
                                "Treat all users with respect and courtesy",
                                "Avoid harassment, bullying, or intimidation",
                                "Do not use discriminatory or hateful language",
                                "Respect diverse perspectives and backgrounds"
                            ]
                        )
                        
                        GuidelineSection(
                            title: "2. Content Standards",
                            points: [
                                "Do not share explicit, inappropriate, or offensive content",
                                "Respect copyright and intellectual property rights",
                                "Do not spam or flood the platform",
                                "Provide accurate and honest information"
                            ]
                        )
                        
                        GuidelineSection(
                            title: "3. Professional Conduct",
                            points: [
                                "Maintain professional standards in all interactions",
                                "Honor contractual agreements and deadlines",
                                "Communicate clearly and transparently with collaborators",
                                "Report disputes or issues promptly"
                            ]
                        )
                        
                        GuidelineSection(
                            title: "4. Campaign Guidelines",
                            points: [
                                "Only propose for campaigns matching your expertise",
                                "Deliver promised deliverables on time",
                                "Disclose sponsored content appropriately",
                                "Follow brand guidelines and specifications"
                            ]
                        )
                        
                        GuidelineSection(
                            title: "5. Prohibited Activities",
                            points: [
                                "Buying or selling followers/engagement",
                                "Using automated engagement tools",
                                "Posting misleading or false information",
                                "Attempting to circumvent platform features"
                            ]
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Violations")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.slate900)
                            
                            Text("Users who violate these guidelines may face warnings, account suspension, or permanent removal from the platform. Severe violations may be reported to appropriate authorities.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Report Issues")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.slate900)
                            
                            Text("If you witness a violation or have concerns about conduct on CreatorBridge, please report it to our moderation team at support@creatorbridge.com.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(20)
            }
            .background(
                colorScheme == .dark ?
                AppTheme.slate900 : Color.white
            )
            .navigationTitle("Community Guidelines")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Accessibility Statement View

struct AccessibilityStatementView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accessibility Statement")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.slate900)
                        
                        Text("Our commitment to inclusive access")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppTheme.slate600)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Section("1. Commitment") {
                            Text("CreatorBridge is committed to ensuring digital accessibility for people with disabilities. We are continually improving the user experience for everyone and applying the relevant accessibility standards.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("2. Accessibility Features") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Our application includes:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("VoiceOver and TalkBack support")
                                BulletPoint("Dynamic Type for adjustable text sizes")
                                BulletPoint("High contrast mode support")
                                BulletPoint("Reduced motion options")
                                BulletPoint("Keyboard navigation support")
                                BulletPoint("Alt text for images")
                            }
                        }
                        
                        Section("3. WCAG Compliance") {
                            Text("We strive to meet WCAG 2.1 Level AA standards. If you have any difficulties accessing our features, please let us know so we can improve our services.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                        
                        Section("4. Known Issues") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("We are aware of and actively working on the following accessibility areas:")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.slate700)
                                
                                BulletPoint("Video content captions (being added)")
                                BulletPoint("Enhanced form labels (in progress)")
                                BulletPoint("Improved color contrast in some UI elements")
                            }
                        }
                        
                        Section("5. Report Accessibility Issues") {
                            Text("If you discover accessibility issues, please report them to accessibility@creatorbridge.com. Include details about the issue and affected area of the application.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppTheme.slate700)
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(20)
            }
            .background(
                colorScheme == .dark ?
                AppTheme.slate900 : Color.white
            )
            .navigationTitle("Accessibility")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helper Components

struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.primary)
            
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.slate700)
                .lineSpacing(2)
        }
    }
}

struct GuidelineSection: View {
    let title: String
    let points: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.slate900)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(points, id: \.self) { point in
                    BulletPoint(point)
                }
            }
        }
    }
}

#Preview {
    PrivacyPolicyFullView()
}
