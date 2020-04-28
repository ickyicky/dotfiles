# copy dotfiles
for SOURCE in `find * -mindepth 1 -type f -not -path ".*/.*/*"`
do
        DESTINATION=~/.`echo "${SOURCE}" | cut -d "/" -f "2-"`
        cp -f ${DESTINATION} ${SOURCE}
done
