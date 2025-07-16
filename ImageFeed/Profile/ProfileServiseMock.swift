//
//  ProfileServiseMock.swift
//  ImageFeed
//
//  Created by Svetlana Varenova on 16.07.2025.
//

import ImageFeed
import Foundation

final class ProfileServiceMock: ProfileServiceProtocol {
    var profile: Profile?
    
    func setProfile(_ profile: Profile) {
        self.profile = profile
    }
} 
