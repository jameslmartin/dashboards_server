# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

FROM node

USER root
RUN useradd -ms /bin/bash node

USER node
RUN mkdir -p /home/node/app/ext

WORKDIR /home/node/app

# 'jupyter-js-widgets' isn't currently published as npm module, so download directly from repo
RUN cd ext && \
    git clone https://github.com/ipython/ipywidgets.git && \
    cd ipywidgets && \
    git checkout 82d1a14df9c79bf9a913965aa9c5f14399adb805
RUN cd ext/ipywidgets/ipywidgets && npm install

# npm & bower install separately, so these are properly cached by docker and not affected by
# changes in rest of source
ADD package.json package.json
RUN npm install

ADD bower.json bower.json
RUN npm run bower

# add everything else
USER root
ADD . /home/node/app
RUN chown -R node:node /home/node/app
USER node

# build our node app
RUN npm run build

EXPOSE 3000
ENTRYPOINT ["npm", "run"]
CMD ["start"]
