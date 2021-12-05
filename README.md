# Forecast

A small iOS app that displays Forecast information for seven days for a given location (where location is determined by zip code) in a collection view. Data is served from the [Aeries API](https://www.aerisweather.com/support/docs/). 

**This project is still under development, and is mainly being used as a tool for learning new iOS APIs**

## Learning Objectives
- Learn how to implement Codable to create Swift objects from nested data sets
- Learn modern CollectionView implementation techniques
  - Learn how to implemenet Diffable Data Source for Collection Views
  - Learn how to implement a custom layout usting UICollectionViewCompoositionalLayout
- Learn how to integrate an advanced networking layer with robust error handling
- Learn an advanced architecture pattern that will help reduce clutter in view controllers (Coordinator?)
- Be able to adapt interface to various trait collections (e.g. size class, dark/light mode)
- Learn how to use Swift's new async/await pattern
- Practice unit testing
- Learn best security practices for storing client ids/secrets, api keys/endpoints
