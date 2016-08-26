echo "Adding project file sorting to Git hooks"
if [ ! -d ".git/hooks" ]; then
  mkdir -p .git/hooks
fi
rm -fr .git/hooks/pre-commit
ln -s ../../sort-project-files.sh .git/hooks/pre-commit
chmod 555 .git/hooks/pre-commit
echo "Done"
