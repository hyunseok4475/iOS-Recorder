//
//  ContentView.swift
//  Audio Recorder
//
//  Created by 송현석 on 2022/01/06.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    
    @State var record = false
    @State var session : AVAudioSession!
    @State var recorder : AVAudioRecorder!
    @State var alert = false
    
    @State var audios : [URL] = []
    
    var body: some View{
        NavigationView{
            VStack{
                
                List(self.audios, id:\.self){i in
                    Text(i.relativeString)
                }
                
                Button(action: {
                    
                    do{
                        
                        if self.record{
                            self.recorder.stop()
                            self.record.toggle()
                            self.getAudios()
                            return
                        }
                        
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        
                        let fileName = url.appendingPathComponent("test.pcm")
                        
                        let settings = [
                            AVFormatIDKey : Int(kAudioFormatLinearPCM),
                            AVSampleRateKey : 8000,
                            AVNumberOfChannelsKey : 1,
                            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
                        ]
                        
                        self.recorder = try AVAudioRecorder(url: fileName, settings: settings)
                        
                        self.recorder.record()
                        self.record.toggle()
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                    
                })
                {
                    ZStack{
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                        
                        if self.record{
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 6)
                                .frame(width: 85, height: 85)
                        }
                    }
                }
                .padding(.vertical, 25)
                
            }
            .navigationTitle("Record Audio")
        }
        .alert(isPresented: self.$alert, content: {
            Alert(title: Text("Error"), message: Text("Enable Access"))
        })
        .onAppear {
            do{
                self.session = AVAudioSession.sharedInstance()
                try session.setCategory(.playAndRecord)
                
                self.session.requestRecordPermission{ (status) in
                    
                    if !status{
                        self.alert.toggle()
                    }
                    else{
                        self.getAudios()
                    }
                    
                }
            }
            catch{
                
            }
        }
    }
    
    func getAudios(){
        do{
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options:.producesRelativePathURLs)
            
            self.audios.removeAll()
            
            for i in result{
                self.audios.append(i)
            }
        }
        catch{
            print(error.localizedDescription)
        }
    }
}
