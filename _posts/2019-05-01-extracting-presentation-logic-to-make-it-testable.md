---
title: Extracting presentation logic to make it testable
description: 
layout: post
published: true
---

[Last week we touched the entirely new topic on my blog. This week we will continue the Unit Testing subject](/2019/04/24/starting-unit-testing-with-model-layer/). One of the smells of a good architecture is the ability to cover it with Unit Tests. Today we will talk about extracting Presentation logic into testable and straightforward pieces of code.

![ShowBot](/public/showbot.jpg)

#### Typical issues
Assume that you have a screen presenting a list of the progress of your TV show collection. Every cell presents TV show poster, title, and next episode number and title. Let's see on typical ShowCell code:

```swift
struct Show: Decodable {
    let title: String
    let images: Images
    let unwatched: [Episode]
}

class ShowCell: UICollectionViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nextEpisodeLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!

    var show: Show? {
        didSet {
            guard let show = show else {
                return
            }

            posterImageView.setImage(from: show.images.poster)
            titleLabel.text = show.title

            if let nextEpisode = show.unwatched.first {
                nextEpisodeLabel.text = "S\(nextEpisode.season)E\(nextEpisode.number) \(nextEpisode.title)"
            }
        }
    }
}
```

This code looks very simple, and at first glance, there are no huge problems. But there are probably a few downsides:

1. We are breaking SOLID principles by mixing presentation logic with view logic inside ShowCell. Our cell is responsible for laying out views and formatting show data into user presentable format.

2. We want to test our data formatting logic to be sure that we are presenting the correct information to the user. But it is hard to cover UIViews with Unit Tests, and there is no clear intention on what you test, layout or presentation logic (we will talk about UI testing in next posts).

#### Refactoring
Let's start to refactor our codebase. First of all, I want to reuse this ShowCell across the app for presenting search response, TV shows collection progress, etc. 

```swift
protocol PosterPresentable {
    var title: String { get }
    var subtitle: String? { get }
    var poster: URL { get }
}

class PosterCell: UICollectionViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!

    var presentation: PosterPresentable? {
        didSet {
            guard let presentation = presentation else {
                return
            }

            posterImageView.setImage(from: presentation.poster)
            titleLabel.text = presentation.title
            subtitleLabel.text = presentation.subtitle
        }
    }
}
```

Here we have refactored version of our ShowCell, now it is called PosterCell, and it can render any data which conforms PosterPresentable protocol. Let's go ahead and create a separated struct which will contain presentation logic for Show model and which we will pass to our cell instead of Show model struct.

```swift
struct ShowPresentation {
    let show: Show
}

extension ShowPresentation: PosterPresentable {
    var title: String {
        return show.title
    }

    var subtitle: String? {
        guard
            let nextEpisode = show.unwatched.first
            else { return nil }
        return "S\(nextEpisode.season)E\(nextEpisode.number) \(nextEpisode.title)"
    }

    var poster: URL {
        return show.images.poster
    }
}
```

By extracting Show model formatting logic into ShowPresentation struct, we fix the encapsulation problem when Cell class responsible for formatting own data model. Another positive effect here is that we can easily cover ShowPresentation with Unit Testing to make sure it works correctly. So, let's continue with implementing tests for our presentation logic.

```swift
class ShowPresentationTests: XCTestCase {
    func testShowPresentation() {
        let mockedImages = Images(
            poster: URL(string: "https://image.tmdb.org/t/p/original/fbtaoynlPpENx3Ss2laC7wgqLIP.jpg")!,
            banner: URL(string: "https://image.tmdb.org/t/p/original/fbtaoynlPpENx3Ss2laC7wgqLIP.jpg")!,
            background: URL(string: "https://image.tmdb.org/t/p/original/fbtaoynlPpENx3Ss2laC7wgqLIP.jpg")!
        )

        let mockedEpisode = Episode(
            title: "The One Where Monica Gets A Roommate",
            season: 1,
            number: 1)

        let mockedShow = Show(
            title: "Friends",
            images: mockedImages,
            unwatched: [mockedEpisode]
        )

        let presentation = ShowPresentation(show: mockedShow)
        XCTAssertEqual(presentation.title, "Friends")
        XCTAssertEqual(presentation.subtitle,  "S1E1 The One Where Monica Gets A Roommate")
        XCTAssertEqual(presentation.poster.absoluteString, "https://image.tmdb.org/t/p/original/fbtaoynlPpENx3Ss2laC7wgqLIP.jpg")
    }
}
```

Here we have a Unit Test which is checking the way of how our Presentation struct formats the data. You might have more fields and more complex logic there. This Unit Test will keep you from breaking the presentation rules of your data in the future during refactoring or any other changes.

#### Conclusion
Today we discussed how easily we could follow the Single responsibility principle during UI development and how we can extract data presentation and formatting logic into testable and reusable pieces of code. We will continue the Unit Testing topic on my blog through the next posts. Just try to refactor your codebase by following the Single responsibility principle.
