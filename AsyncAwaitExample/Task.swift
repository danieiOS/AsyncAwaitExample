//
//  Task.swift
//  AsyncAwaitExample
//
//  Created by 송성욱 on 10/29/23.
//

import SwiftUI
//구현 목표
/// - async, await를 사용할 때의 스레드 환경 파악하기
/// - Actor를 활용한 스레드 환경 조성하기
//구현 Task
/// - GCD의 종류에 따른 스레드 환경 확인하기
/// - sleep 등 비동기 함수를 실행한 이후 스레드 환경 파악하기
/// - MainActor 내부의 스레드 상황 파악하기
class AsyncAwaitVM: ObservableObject {
    
    @Published var dataArray = [String]()
    
    func addFirstTitle() {
        dataArray.append("Title1 : \(Thread.current) \nIs Main? : \(Thread.isMainThread)")
    }
    
    func addSecondTitle() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let secondTitle = "Title2 : \(Thread.current) \nIs Main? : \(Thread.isMainThread)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dataArray.append(secondTitle)
                self.dataArray.append("Title3: \(Thread.current) \nIs Main? : \(Thread.isMainThread)")
            }
        }
    }
    
    func addFirstAuthor() async {
        let firstAuthor = "Author1: \(Thread.current)"
        self.dataArray.append(firstAuthor)
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        // after sleep -> thread : not main thread
        // try? await doSomething()
        // await -> suspension point
        let secondAuthor = "Author2: \(Thread.current)"
        // after sleep -> thread : Main thread
        await MainActor.run {
            self.dataArray.append(secondAuthor)
            let thirdAuthor = "Author3: \(Thread.current)"
            self.dataArray.append(thirdAuthor)
        }
        await addSomething()
    }
    
    func doSomething() async throws {
        print("do Something")
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let firstSomething = "Something1 \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(firstSomething)
            
            let secondSomething = "Something2 \(Thread.current)"
            self.dataArray.append(secondSomething)
        }
    }
}

/// - 햔재 코드가 실행되는 스레드 환경들을 Print
/// - Task.sleep을 통해서 현 스레드(메인)가 다른 스레드로 바뀌지만 doSomething이라는 함수를 통해서 바뀌지 않는 다는걸 파악
/// - --> async 함수라 할지라도 스레드 환경이 코드에 따라 달라짐
