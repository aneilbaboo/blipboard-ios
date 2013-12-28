task :default do
  puts "*******************************************************************************************"
  puts "Running rake -T to print out usage..."
  puts "*******************************************************************************************"
  sh 'rake -T'
end

desc "Run xcodebuild on the BlipboardTests scheme."
task :test => [:clean] do
  puts "Running xcodebuild to run unit tests..."
  sh "xcodebuild -target BlipboardTests -configuration Debug -sdk iphonesimulator"
end

desc "Runs xcodebuild clean."
task :clean do
  sh "xcodebuild clean"
end

