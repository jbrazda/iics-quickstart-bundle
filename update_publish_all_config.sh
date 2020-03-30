find ./src/ipd -name "*.AI_SERVICE_CONNECTOR.xml" | gsed -r 's/(\.\/src\/ipd\/)|(\.xml)//g' > conf/all_designs.publish.txt&&\fCC
find ./src/ipd -name "*.AI_CONNECTION.xml" | gsed -r 's/(\.\/src\/ipd\/)|(\.xml)//g' >> conf/all_designs.publish.txt&&\
find ./src/ipd -name "*.PROCESS.xml" | gsed -r 's/(\.\/src\/ipd\/)|(\.xml)//g' >> conf/all_designs.publish.txt&&\
find ./src/ipd -name "*.GUIDE.xml" | gsed -r 's/(\.\/src\/ipd\/)|(\.xml)//g' >> conf/all_designs.publish.txt