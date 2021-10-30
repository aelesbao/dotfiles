#!/bin/zsh

mkdir -p ~/gh-contributions

for i in {1..10}; do
  echo "Fetching PullRequestEvent / page $i"
  gh-api "/users/aelesbao/events?page=$i&per_page=1000" '.[] | select(.type == "PullRequestEvent" and .payload.action == "opened")' | \
    jq '{ repo: .repo.name, title: .payload.pull_request.title, url: .payload.pull_request.url, created_at: .created_at }' | \
    tee ~/gh-contributions/page-$i.json
done
